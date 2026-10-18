# SEAT-20 PROBE — relative markdown link integrity, vendored `corpus/knowledge/unreal-mcp/upstream/`

Round: r101 · Seat: SEAT-20 (probe) · Date: 2026-10-18
Lane axes: depth / coverage / calibration — this probe serves **coverage** (C1).

## 0. Verdict

**3 markdown links exist in the 6 vendored `.md` files. 0 broken. 0 unresolved anchors.**
2 are relative and both resolve to files present in the vendored tree; 1 is an absolute URL
(HTTP 200 when fetched). The four apparent `[this]()` "links" in
`skills/create-toolset/SKILL.md` are **not links** — they are C++ lambda captures inside a
fenced ```` ```cpp ```` block.

| Metric | Count |
|---|---|
| vendored `.md` files scanned | 6 |
| links total (inline + reference-definition) | 3 |
| relative links, target exists in tree | 2 |
| same-file `#fragment`-only links | 0 |
| absolute-URL links | 1 |
| **broken relative links** | **0** |
| links whose `#anchor` does not exist in target | **0** |

## 1. Upstream pin verification (precondition for every claim below)

Command:

```
$ git -C /tmp/ue-skills-ref rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Observed output equals the round-pinned SHA `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
No fresh clone was needed; `/tmp/r101work` was not created.

The six scanned files are **byte-identical** to the upstream blob at that SHA — verified by
comparing `git show <pin>:<path>` hashes against the working-tree hashes:

```
$ for f in README.md skills/create-toolset/SKILL.md skills/unreal-mcp/SKILL.md \
           skills/unreal-mcp/references/operations.md \
           skills/unreal-mcp/references/setup.md skills/unreal-skill/SKILL.md; do
    a=$(git -C /tmp/ue-skills-ref show "a6aa73ada02a9fb1f5415bec491f9942c519b297:$f" | sha256sum | cut -d' ' -f1)
    b=$(sha256sum "corpus/knowledge/unreal-mcp/upstream/$f" | cut -d' ' -f1)
    [ "$a" = "$b" ] && echo "IDENTICAL $f" || echo "DIFF      $f"
  done
IDENTICAL README.md
IDENTICAL skills/create-toolset/SKILL.md
IDENTICAL skills/unreal-mcp/SKILL.md
IDENTICAL skills/unreal-mcp/references/operations.md
IDENTICAL skills/unreal-mcp/references/setup.md
IDENTICAL skills/unreal-skill/SKILL.md
```

So this is a link check against the real upstream bytes, not against a re-typed copy.
Note: `skills/create-toolset/SKILL.md` landed in the tree **during** this probe (another seat
vendored it concurrently); an earlier pass saw only 5 `.md` files. All numbers below are from
the post-arrival state, and the probe script is re-runnable to reconfirm.

Per-file SHA-256 of the scanned files:

| file | bytes | sha256 |
|---|---|---|
| `README.md` | 8398 | `483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e` |
| `skills/create-toolset/SKILL.md` | 23258 | `e9d050087f36de51f7eeef49adb0ba9ebc603b65f74f475bc53a6debfc1f7b1c` |
| `skills/unreal-mcp/SKILL.md` | 7098 | `7ef8b991a82f591c5776bb5fa167c2bc2269fd00338ed3e8534eacc551d038fa` |
| `skills/unreal-mcp/references/operations.md` | 6497 | `dbed002b4a46ab104274a31eb6682c3d277ce669216d0378df709f51567c3113` |
| `skills/unreal-mcp/references/setup.md` | 6065 | `bd16206ea142dc9cc1950b88af526a3137072ea152c5662e8549d21bc18a3b8a` |
| `skills/unreal-skill/SKILL.md` | 6955 | `7a0af781c458c7d192d6b23c16b5737922dc482470e2e4ef617bcda80f435087` |

## 2. Every relative link, with resolution evidence

### 2.1 Relative links — target exists in the vendored tree (2/2)

Both live on the same source line, `README.md:80`:

```
$ sed -n '80p' corpus/knowledge/unreal-mcp/upstream/README.md
See [proxy setup](skills/unreal-mcp/references/setup.md#4-optional-install-the-proxy) for platform binaries and installation commands. See [proxy recovery](skills/unreal-mcp/references/operations.md#proxy-recovery) for status, cached catalogs, and connection failures.
```

| # | source | label | target (verbatim) | resolves to | file exists | anchor exists |
|---|---|---|---|---|---|---|
| 1 | `README.md:80` | `proxy setup` | `skills/unreal-mcp/references/setup.md#4-optional-install-the-proxy` | `skills/unreal-mcp/references/setup.md` | yes | yes |
| 2 | `README.md:80` | `proxy recovery` | `skills/unreal-mcp/references/operations.md#proxy-recovery` | `skills/unreal-mcp/references/operations.md` | yes | yes |

Both are relative to `README.md`'s own directory, which is the tree root of the vendored
`upstream/`, so `skills/...` resolves inside the vendored tree. Neither escapes the vendored
root. Existence check:

```
$ find corpus/knowledge/unreal-mcp/upstream -type f -name '*.md' | sort
corpus/knowledge/unreal-mcp/upstream/README.md
corpus/knowledge/unreal-mcp/upstream/skills/create-toolset/SKILL.md
corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/operations.md
corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/setup.md
corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/SKILL.md
corpus/knowledge/unreal-mcp/upstream/skills/unreal-skill/SKILL.md
```

### 2.2 Anchor (`#fragment`) verification

Anchors were checked by slugifying each heading in the target file with the GitHub rule
(lowercase, strip punctuation except `-`/`_`, spaces → `-`) and comparing.

```
$ grep -nE '^\s{0,3}#{1,6} ' corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/setup.md
1:# First-Time MCP Server Setup
12:## 1. Enable the plugins in the `.uproject`
33:## 2. Enable auto-start
57:## 3. Generate `.mcp.json`
83:## 4. Optional: install the proxy
123:## Verifying
```

Link 1's fragment `#4-optional-install-the-proxy` matches line 83's heading `## 4. Optional:
install the proxy` — slug is `4-optional-install-the-proxy` (the `.` after `4` is stripped,
`:` stripped, spaces → `-`). Match.

```
$ grep -nE '^\s{0,3}#{1,6} ' corpus/knowledge/unreal-mcp/upstream/skills/unreal-mcp/references/operations.md
1:# Operations: Console Commands, Settings, Recovery
5:## Console commands
16:## Tool-search mode
30:## Proxy recovery
42:## Troubleshooting matrix
```

Link 2's fragment `#proxy-recovery` matches line 30's heading `## Proxy recovery`. Match.

Caveat, stated plainly: anchor matching here uses the standard GitHub slug rule. GitHub's
real renderer can differ for headings containing emoji or duplicate headings; neither occurs
in these two targets, so the slugs above are unambiguous. The **file** half of each link is
verified by direct filesystem existence, independent of any slug rule.

### 2.3 Absolute-URL links — listed separately (1)

| # | source | label | target | reachability |
|---|---|---|---|---|
| 1 | `README.md:32` | `claude.com/plugins` | `https://claude.com/plugins` | HTTP 200 |

```
$ sed -n '32p' corpus/knowledge/unreal-mcp/upstream/README.md
This plugin is published in Anthropic's official Claude Code plugin marketplace, `claude-plugins-official`, which is available automatically when you start Claude Code. Browse it at [claude.com/plugins](https://claude.com/plugins) or in the **Discover** tab of the `/plugin` panel.
```

```
$ curl -sS -o /dev/null -w 'http_code=%{http_code} url=%{url_effective}\n' -L --max-time 20 https://claude.com/plugins
http_code=200 url=https://claude.com/marketplace/plugins
```

Reachable, with a permanent-looking redirect to `claude.com/marketplace/plugins`. This is an
outbound network check only; it carries no claim about the plugin's availability inside any
Claude Code installation.

### 2.4 Same-file fragment-only links (0)

None found. No link in the vendored tree has an empty path component.

## 3. Broken links

**None.** 0 broken relative links, 0 unresolved anchors, 0 relative links escaping the
vendored root.

## 4. False-positive exclusion — the `[this]()` occurrences

A naive `grep -o ']('` reports 4 hits in `skills/create-toolset/SKILL.md`. All 4 are C++
lambda captures, not markdown links. Proof — the fence boundaries bracket them:

```
$ grep -nE ']\(|^```|^~~~' corpus/knowledge/unreal-mcp/upstream/skills/create-toolset/SKILL.md
238:```cpp
247:    Describe("FindThings", [this]()
249:        It("returns matching things", [this]()
255:        It("returns an empty array when no things match", [this]()
261:        It("raises when the name pattern is empty", [this]()
268:```
```

Lines 247–261 sit strictly between the ```` ```cpp ```` fence opened at 238 and closed at 268.
They are also empty-target links (`[this]()`) and are inside a code block, so no markdown
renderer treats them as links. The probe excludes fenced code blocks by construction.

Raw counts for transparency:

```
$ for f in $(find . -name '*.md' | sort); do printf '%-50s %s\n' "$f" "$(grep -o '](' "$f" | wc -l)"; done
./README.md                                        3
./skills/create-toolset/SKILL.md                   4
./skills/unreal-mcp/references/operations.md       0
./skills/unreal-mcp/references/setup.md            0
./skills/unreal-mcp/SKILL.md                       0
./skills/unreal-skill/SKILL.md                     0
```

Raw `](` count = 7; link count after fence/inline-code exclusion and empty-target handling = 3.
The 4-hit gap is exactly the excluded C++ block. Note `README.md`'s raw count of 3 equals its
link count of 3 — no exclusions were needed there.

## 5. Coverage of link syntaxes

Swept for, and their observed result:

```
$ grep -rnoE '\[[^]]+\]\[[^]]*\]' --include='*.md' .          # reference-style usage [x][y]
(none above = none)
$ grep -rnoE '^\[[^]]+\]: *\S+' --include='*.md' .            # reference definitions [id]: url
(no output)
$ grep -rnoiE '<(a|img)[^>]*(href|src)=' --include='*.md' .   # raw HTML anchors/images
(none above = none)
$ grep -rnoE '<https?://[^>]*>' --include='*.md' .            # bare autolinks
(no output)
```

A Python sweep additionally confirmed there are no links split across a newline
(`]` … newline … `(`), no links hidden inside HTML comments, and no bracket imbalance in any
of the 6 files:

```
$ python3 - <<'EOF'   # (see §7 for the full script)
...
EOF
multiline/comment sweep done for 6 files
```

Conclusion: this upstream uses **only** the inline `[text](target)` form. The 3-link total is
the complete link inventory, not a subset that a parser shape missed.

## 6. Negative control — the probe can fail

A 0-broken result is only evidence if the detector detects. Control run on a copy of the
tree with three injected links (one bad relative target, one bad anchor, one absolute URL),
appended after a fenced block that also contains a bad link:

```
$ rm -rf /tmp/negctl && mkdir -p /tmp/negctl && cp -r corpus/knowledge/unreal-mcp/upstream/. /tmp/negctl/
$ printf '\n[x](missing/nope.md)\n[y](skills/unreal-mcp/references/setup.md#no-such-heading)\n[z](https://example.com)\n```\n[fake](also/missing.md)\n```\n' >> /tmp/negctl/README.md
$ python3 /tmp/r101-seat20-probe.py /tmp/negctl | python3 -c "import json,sys; d=json.load(sys.stdin); print('broken:', json.dumps(d['broken'])); print('unresolved_anchors:', json.dumps(d['unresolved_anchors'])); print('absolute_urls:', [u['target'] for u in d['absolute_urls']]); print('totals:', d['totals'])"
broken: [{"file": "README.md", "kind": "inline", "label": "x", "line": 114, "resolved": "missing/nope.md", "target": "missing/nope.md"}]
unresolved_anchors: [{"file": "README.md", "kind": "inline", "label": "y", "line": 115, "resolved": "skills/unreal-mcp/references/setup.md", "target": "skills/unreal-mcp/references/setup.md#no-such-heading"}]
absolute_urls: ['https://claude.com/plugins', 'https://example.com']
totals: {'absolute_urls': 2, 'broken': 1, 'links_total': 5, 'md_files': 6, 'relative_resolved': 3, 'same_file_fragments': 0, 'unresolved_anchors': 1}
```

Exactly the injected failures were reported: `broken` = 1 (the real bad link), `unresolved_anchors`
= 1 (the real bad anchor), `absolute_urls` = 2 (original + injected). The `[fake](also/missing.md)`
inside the appended fence was **not** counted as broken — fence exclusion holds. The clean-tree
run's 0 broken / 0 unresolved is therefore a genuine pass, not detector blindness.

## 7. Reproduction

Probe script: `/tmp/r101-seat20-probe.py` (kept out of the repo; this seat's declared write path
is only `reports/round-101/probes/md-links.md`). Full source, so the probe is re-runnable from
this report alone:

```python
#!/usr/bin/env python3
"""SEAT-20 probe: extract markdown links from a tree, verify relative targets exist.

Usage: probe.py ROOT   (ROOT = directory containing .md files, e.g. the vendored upstream/)
Emits a deterministic JSON summary to stdout.
"""
import json
import os
import re
import sys

FENCE = re.compile(r'^(\s*)(`{3,}|~{3,})')
INLINE_CODE = re.compile(r'(`+)(?:(?!\1).)*\1')
INLINE_LINK = re.compile(r'(!?)\[([^\]]*)\]\(\s*(<[^>]*>|[^()\s]*(?:\([^()]*\)[^()\s]*)*)(?:\s+"[^"]*")?\s*\)')
REF_DEF = re.compile(r'^\s{0,3}\[([^\]]+)\]:\s*(\S+)')
SCHEME = re.compile(r'^[a-zA-Z][a-zA-Z0-9+.\-]*:')


def strip_code(text):
    """Blank out fenced code blocks and inline code spans (preserving line count)."""
    out, in_fence, fence_tok = [], False, None
    for line in text.split('\n'):
        m = FENCE.match(line)
        if in_fence:
            if m and m.group(2)[0] == fence_tok[0] and len(m.group(2)) >= len(fence_tok):
                in_fence = False
            out.append('')
            continue
        if m:
            in_fence, fence_tok = True, m.group(2)
            out.append('')
            continue
        out.append(INLINE_CODE.sub(lambda mm: ' ' * len(mm.group(0)), line))
    return '\n'.join(out)


def slug(text):
    """GitHub heading -> anchor slug."""
    s = text.strip().lower()
    s = re.sub(r'[^\w\- ]', '', s)
    return s.replace(' ', '-')


def headings(text):
    anchors = set()
    for line in text.split('\n'):
        m = re.match(r'^\s{0,3}(#{1,6})\s+(.*?)\s*$', line)
        if m:
            anchors.add(slug(m.group(2)))
    return anchors


def split_target(raw):
    raw = raw.strip()
    if raw.startswith('<') and raw.endswith('>'):
        raw = raw[1:-1]
    path, _, frag = raw.partition('#')
    return path, frag


def main():
    root = os.path.abspath(sys.argv[1])
    mds = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d != '.git']
        for f in filenames:
            if f.endswith('.md'):
                mds.append(os.path.join(dirpath, f))
    mds.sort()

    anchor_cache = {}
    def anchors_of(path):
        if path not in anchor_cache:
            try:
                with open(path, 'r', encoding='utf-8', errors='replace') as fh:
                    anchor_cache[path] = headings(fh.read())
            except OSError:
                anchor_cache[path] = set()
        return anchor_cache[path]

    rel_links, abs_urls, fragments, broken, bad_anchor = [], [], [], [], []
    per_file = {}

    for md in mds:
        rel = os.path.relpath(md, root)
        with open(md, 'r', encoding='utf-8', errors='replace') as fh:
            raw_text = fh.read()
        text = strip_code(raw_text)
        found = []
        for lineno, line in enumerate(text.split('\n'), 1):
            for m in INLINE_LINK.finditer(line):
                found.append((lineno, m.group(2), m.group(3), 'inline'))
            r = REF_DEF.match(line)
            if r:
                found.append((lineno, r.group(1), r.group(2), 'refdef'))
        per_file[rel] = len(found)
        for lineno, label, target, kind in found:
            path, frag = split_target(target)
            rec = {'file': rel, 'line': lineno, 'label': label,
                   'target': target, 'kind': kind}
            if SCHEME.match(path):
                abs_urls.append(rec)
                continue
            if path == '':
                rec['resolved'] = rel
                if frag and frag not in anchors_of(md):
                    bad_anchor.append(rec)
                fragments.append(rec)
                continue
            resolved = os.path.normpath(os.path.join(os.path.dirname(md), path))
            rec['resolved'] = os.path.relpath(resolved, root)
            if not os.path.exists(resolved):
                broken.append(rec)
                continue
            rel_links.append(rec)
            if frag and resolved.endswith('.md'):
                if frag not in anchors_of(resolved):
                    bad_anchor.append(rec)

    print(json.dumps({
        'root': root,
        'md_files': [os.path.relpath(m, root) for m in mds],
        'per_file_link_counts': per_file,
        'relative_links': rel_links,
        'same_file_fragments': fragments,
        'absolute_urls': abs_urls,
        'broken': broken,
        'unresolved_anchors': bad_anchor,
        'totals': {
            'md_files': len(mds),
            'links_total': len(rel_links) + len(abs_urls) + len(fragments),
            'relative_resolved': len(rel_links),
            'same_file_fragments': len(fragments),
            'absolute_urls': len(abs_urls),
            'broken': len(broken),
            'unresolved_anchors': len(bad_anchor),
        },
    }, indent=2, sort_keys=True))


if __name__ == '__main__':
    main()
```

Re-run:

```
$ python3 /tmp/r101-seat20-probe.py corpus/knowledge/unreal-mcp/upstream
```

Observed output (abridged to the verdict fields; full JSON includes per-file counts and every
link record):

```
"broken": [],
"unresolved_anchors": [],
"totals": {
  "absolute_urls": 1,
  "broken": 0,
  "links_total": 3,
  "md_files": 6,
  "relative_resolved": 2,
  "same_file_fragments": 0,
  "unresolved_anchors": 0
}
```

## 8. Scope and limits

- Scope is exactly the **vendored** tree `corpus/knowledge/unreal-mcp/upstream/`. Links in
  non-`.md` vendored files (`hooks/unreal-context.sh`, `hooks/hooks.json`,
  `.claude-plugin/plugin.json`, `CODEOWNERS`, `.gitignore`, `LICENSE`) were not checked —
  they are out of this seat's declared scope. `unreal-context.sh` is a shell script and is
  another seat's `shellcheck` target.
- No inbound link into the vendored tree exists from elsewhere in this repo; a repo-wide sweep
  found zero non-upstream `.md` files mentioning `unreal-mcp`, so there are no repo-side
  references that could rot when the vendored tree is re-pinned.
- Relative links are checked as **filesystem existence**, which is what a reader's editor
  jump does. A `.md` target whose anchor resolves is additionally checked for the anchor; a
  non-`.md` target is only existence-checked. Both relative targets here are `.md`.
- The absolute URL was fetched once, over the network, from this host. Reachability of a
  third-party site is not a property of the vendored artifact and may change independently;
  it is recorded as an observation with its timestamp-bearing command, not as a durable claim.
- The tree changed under this probe (`create-toolset/SKILL.md` arrived mid-run from a
  concurrent seat). The reported 3-link result is for the 6-file state; if further files land,
  re-running the script in §7 re-derives it.
- No claim here touches Unreal Editor, MCP runtime, or any live-editor behaviour. Unreal
  Editor is not installed on this host; that remains unproven-on-this-host by construction.
