# SEAT-38 RERUN — vendored-markdown link check, `corpus/knowledge/unreal-mcp/upstream/`

Round: r102 · Seat: SEAT-38 (LINKCHECK-RERUN) · Date: 2026-10-18
Lane axes: depth / coverage / calibration — this rerun serves **coverage** (C1).

## 0. Verdict

**Re-run reproduces the r101 SEAT-20 result exactly: 6 vendored `.md` files, 3 links, 0 broken,
0 unresolved anchors.** No regression, no drift, and the probe still detects injected failures.

| Metric | r101 (SEAT-20) | r102 (this rerun) | agree |
|---|---|---|---|
| vendored `.md` files scanned | 6 | 6 | yes |
| links total | 3 | 3 | yes |
| relative links resolving in tree | 2 | 2 | yes |
| same-file `#fragment`-only links | 0 | 0 | yes |
| absolute-URL links | 1 | 1 | yes |
| **broken relative links** | **0** | **0** | yes |
| **unresolved anchors** | **0** | **0** | yes |

Baseline being re-run: `reports/round-101/probes/md-links.md` (SEAT-20), verdict §0 — "3 markdown
links exist in the 6 vendored `.md` files. 0 broken. 0 unresolved anchors."

## 1. Precondition — upstream pin and byte-identity

The reference clone still sits on the round pin:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

All six scanned files are byte-identical to the upstream blob at that SHA:

```
$ for f in README.md skills/create-toolset/SKILL.md skills/unreal-mcp/SKILL.md \
           skills/unreal-mcp/references/operations.md \
           skills/unreal-mcp/references/setup.md skills/unreal-skill/SKILL.md; do
    a=$(git -C /tmp/ue-skills-ref show "a6aa73ada02a9fb1f5415bec491f9942c519b297:$f" | sha256sum | cut -d' ' -f1)
    b=$(sha256sum "corpus/knowledge/unreal-mcp/upstream/$f" | cut -d' ' -f1)
    printf '%-48s %s\n' "$f" "$([ "$a" = "$b" ] && echo IDENTICAL || echo DIFF)"
  done
README.md                                        IDENTICAL
skills/create-toolset/SKILL.md                   IDENTICAL
skills/unreal-mcp/SKILL.md                       IDENTICAL
skills/unreal-mcp/references/operations.md       IDENTICAL
skills/unreal-mcp/references/setup.md            IDENTICAL
skills/unreal-skill/SKILL.md                     IDENTICAL
```

Per-file SHA-256 of the worktree copies — every value equals the r101 SEAT-20 table in
`reports/round-101/probes/md-links.md:64-69`, i.e. the subtree did not drift between rounds:

```
$ sha256sum corpus/knowledge/unreal-mcp/upstream/README.md \
            corpus/knowledge/unreal-mcp/upstream/skills/create-toolset/SKILL.md \
            corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md \
            corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/operations.md \
            corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/setup.md \
            corpus/knowledge/unreal-mcp/upstream/skills/unreal-skill/SKILL.md
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  corpus/knowledge/unreal-mcp/upstream/README.md
e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c  corpus/knowledge/unreal-mcp/upstream/skills/create-toolset/SKILL.md
7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa  corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113  corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/operations.md
bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a  corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/setup.md
7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087  corpus/knowledge/unreal-mcp/upstream/skills/unreal-skill/SKILL.md
```

No modification is pending inside `upstream/`:

```
$ git status --porcelain corpus/knowledge/unreal-mcp
 M corpus/knowledge/unreal-mcp/README.md
```

The single modified path is the subtree-root README (another seat's F8 wording fold, §"`':187'`
`12 lines`" ambiguity); `upstream/` itself is clean at HEAD. This rerun wrote nothing under
`corpus/`.

## 2. Probe execution

The probe is re-derived from the r101 report itself, not from an untracked `/tmp` file, so the
check is self-contained. Extraction of the fenced `python` block at
`reports/round-101/probes/md-links.md:256-399`:

```
$ python3 - <<'EOF'
import re
rep=open('reports/round-101/probes/md-links.md',encoding='utf-8').read()
blocks=re.findall(r'```python\n(.*?)```',rep,re.S)
print('python blocks found:',len(blocks))
open('/tmp/r101-seat20-probe-from-report.py','w',encoding='utf-8').write(blocks[0])
EOF
python blocks found: 1
```

Run against the byte-pinned tree:

```
$ python3 /tmp/r101-seat20-probe-from-report.py corpus/knowledge/unreal-mcp/upstream
```

Full JSON summary, verbatim:

```json
{
  "absolute_urls": [
    {
      "file": "README.md",
      "kind": "inline",
      "label": "claude.com/plugins",
      "line": 32,
      "target": "https://claude.com/plugins"
    }
  ],
  "broken": [],
  "md_files": [
    "README.md",
    "skills/create-toolset/SKILL.md",
    "skills/unreal-mcp/SKILL.md",
    "skills/unreal-mcp/references/operations.md",
    "skills/unreal-mcp/references/setup.md",
    "skills/unreal-skill/SKILL.md"
  ],
  "per_file_link_counts": {
    "README.md": 3,
    "skills/create-toolset/SKILL.md": 0,
    "skills/unreal-mcp/SKILL.md": 0,
    "skills/unreal-mcp/references/operations.md": 0,
    "skills/unreal-mcp/references/setup.md": 0,
    "skills/unreal-skill/SKILL.md": 0
  },
  "relative_links": [
    {
      "file": "README.md",
      "kind": "inline",
      "label": "proxy setup",
      "line": 80,
      "resolved": "skills/unreal-mcp/references/setup.md",
      "target": "skills/unreal-mcp/references/setup.md#4-optional-install-the-proxy"
    },
    {
      "file": "README.md",
      "kind": "inline",
      "label": "proxy recovery",
      "line": 80,
      "resolved": "skills/unreal-mcp/references/operations.md",
      "target": "skills/unreal-mcp/references/operations.md#proxy-recovery"
    }
  ],
  "root": "/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin/corpus/knowledge/unreal-mcp/upstream",
  "same_file_fragments": [],
  "totals": {
    "absolute_urls": 1,
    "broken": 0,
    "links_total": 3,
    "md_files": 6,
    "relative_resolved": 2,
    "same_file_fragments": 0,
    "unresolved_anchors": 0
  },
  "unresolved_anchors": []
}
```

`broken` is `[]` and `unresolved_anchors` is `[]` — the 0-broken baseline holds.

### 2.1 Two script copies, identical verdict

The r101 report embedded the script with comments/docstring trimmed relative to the original
`/tmp/r101-seat20-probe.py`:

```
$ sha256sum /tmp/r101-seat20-probe-from-report.py /tmp/r101-seat20-probe.py
6b02a6c5d244044a6beb239c8772c35d193eaf7591133e1184f04e003d0811aa  /tmp/r101-seat20-probe-from-report.py
4a731dc5f1eb6e0a087464f3c0dd1b0358a5b1b4e2083463700d04b1ea343d51  /tmp/r101-seat20-probe.py
```

```
$ diff /tmp/r101-seat20-probe-from-report.py /tmp/r101-seat20-probe.py
5c5
< Emits a deterministic JSON summary to stdout.
---
> Emits a deterministic TSV/JSON summary to stdout.
13a14
> # [text](target) / ![alt](target)  -- target may be <...> or contain one level of parens
14a16
> # [id]: target
104a107
>                 # same-file fragment
```

All four hunks are a docstring word and comment lines — no executable difference. Confirmed
by output equality:

```
$ python3 /tmp/r101-seat20-probe.py corpus/knowledge/unreal-mcp/upstream > /tmp/r102-links.json
$ python3 /tmp/r101-seat20-probe-from-report.py corpus/knowledge/unreal-mcp/upstream > /tmp/r102-links-fromreport.json
$ python3 -c "import json; print(json.load(open('/tmp/r102-links.json'))==json.load(open('/tmp/r102-links-fromreport.json')))"
True
```

## 3. Independent cross-check of the link inventory

Raw `](` counts, unfiltered:

```
$ for f in $(find . -name '*.md' | sort); do printf '%-50s %s\n' "$f" "$(grep -o '](' "$f" | wc -l)"; done
./README.md                                        3
./skills/create-toolset/SKILL.md                   4
./skills/unreal-mcp/references/operations.md       0
./skills/unreal-mcp/references/setup.md            0
./skills/unreal-mcp/SKILL.md                       0
./skills/unreal-skill/SKILL.md                     0
```

Same-file counts after blanking fenced code blocks — the four `create-toolset` hits are the C++
lambda captures and vanish:

```
$ for f in $(find . -name '*.md' | sort); do printf '%-50s %s\n' "$f" "$(awk 'BEGIN{f=0} /^\s*(```|~~~)/{f=!f; next} !f' "$f" | grep -o '](' | wc -l)"; done
./README.md                                        3
./skills/create-toolset/SKILL.md                   0
./skills/unreal-mcp/references/operations.md       0
./skills/unreal-mcp/references/setup.md            0
./skills/unreal-mcp/SKILL.md                       0
./skills/unreal-skill/SKILL.md                     0
```

The three surviving links are exactly the probe's three, and both source lines are as cited:

```
$ grep -n '](' README.md
32:This plugin is published in Anthropic's official Claude Code plugin marketplace, `claude-plugins-official`, which is available automatically when you start Claude Code. Browse it at [claude.com/plugins](https://claude.com/plugins) or in the **Discover** tab of the `/plugin` panel.
80:See [proxy setup](skills/unreal-mcp/references/setup.md#4-optional-install-the-proxy) for platform binaries and installation commands. See [proxy recovery](skills/unreal-mcp/references/operations.md#proxy-recovery) for status, cached catalogs, and connection failures.
```

## 4. Negative control — the rerun can fail

Detector liveness re-established this round on a scratch copy (three injected links: bad
relative target, bad anchor, absolute URL, plus a fourth bad link inside an appended fence):

```
$ rm -rf /tmp/negctl-r102 && mkdir -p /tmp/negctl-r102 && cp -r corpus/knowledge/unreal-mcp/upstream/. /tmp/negctl-r102/
$ printf '\n[x](missing/nope.md)\n[y](skills/unreal-mcp/references/setup.md#no-such-heading)\n[z](https://example.com)\n```\n[fake](also/missing.md)\n```\n' >> /tmp/negctl-r102/README.md
$ python3 /tmp/r101-seat20-probe.py /tmp/negctl-r102
broken: [{"file": "README.md", "kind": "inline", "label": "x", "line": 114, "resolved": "missing/nope.md", "target": "missing/nope.md"}]
unresolved_anchors: [{"file": "README.md", "kind": "inline", "label": "y", "line": 115, "resolved": "skills/unreal-mcp/references/setup.md", "target": "skills/unreal-mcp/references/setup.md#no-such-heading"}]
absolute_urls: ['https://claude.com/plugins', 'https://example.com']
totals: {"absolute_urls": 2, "broken": 1, "links_total": 5, "md_files": 6, "relative_resolved": 3, "same_file_fragments": 0, "unresolved_anchors": 1}
```

(Last line rendered above with `"`; the command actually emitted a Python dict repr with `'`
quotes — `{'absolute_urls': 2, 'broken': 1, 'links_total': 5, 'md_files': 6,
'relative_resolved': 3, 'same_file_fragments': 0, 'unresolved_anchors': 1}` — because the
one-liner printed `d['totals']` directly instead of `json.dumps`-ing it. Values are identical.)

Byte-for-byte the r101 control output (`reports/round-101/probes/md-links.md:239-242`): the
injected breakage is reported, the in-fence `[fake](also/missing.md)` is not. The clean-tree
`broken: []` is therefore a real pass, not detector blindness.

## 5. Absolute URL, re-observed

```
$ curl -sS -o /dev/null -w 'http_code=%{http_code} url=%{url_effective}\n' -L --max-time 20 https://claude.com/plugins
http_code=200 url=https://claude.com/marketplace/plugins
```

Observed 2026-10-18T17:41:24Z, same 200 + redirect target as r101. Outbound network check only;
it is an observation with a timestamp, not a durable property of the vendored artifact.

## 6. Scope and limits

- Scope is exactly `corpus/knowledge/unreal-mcp/upstream/`. Non-`.md` vendored files
  (`hooks/unreal-context.sh`, `hooks/hooks.json`, `.claude-plugin/plugin.json`, `CODEOWNERS`,
  `.gitignore`, `LICENSE`) are out of scope; `unreal-context.sh` belongs to the shellcheck seat.
- This is a **rerun**, not a new probe: the script is taken verbatim from the r101 report, so
  it re-tests the same detector. It cannot discover link syntaxes the r101 sweep shape missed
  (that limitation is unchanged from `reports/round-101/probes/md-links.md:424-444`).
- Relative links are verified as filesystem existence plus, for `.md` targets, a GitHub-slug
  anchor match. Both relative targets here are `.md`, so both get the anchor check.
- `corpus/knowledge/unreal-mcp/README.md` is modified in the working tree by another seat
  (F8 wording fold). That file is **not** part of `upstream/` and was not scanned; no
  conclusion here depends on it.
- No claim here touches Unreal Editor, the MCP server, or any live-editor behaviour. The
  editor is not installed on this host; live-MCP behaviour is unproven by construction.

## 7. Files written by this seat

- `reports/round-102/reruns/links.md` (this file) — the only path this seat owns.
- Scratch, outside the repo: `/tmp/r102-links.json`, `/tmp/r102-links-fromreport.json`,
  `/tmp/r101-seat20-probe-from-report.py`, `/tmp/negctl-r102/`.
