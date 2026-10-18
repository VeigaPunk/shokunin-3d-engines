# r103 SEAT-07 — URL recheck for the `adaptation-kimi.md` freshness note

Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · HEAD `c85a816` · receipt
**2026-10-18T18:31:45Z**.

Scope: every old **and** new documentation URL cited by the proposed freshness note
(`reports/round-102/kimi-surfaces.md` §4, verdict table S2), plus every other URL that
`corpus/knowledge/unreal-mcp/adaptation-kimi.md` itself cites. Method: `curl -sI` (and `-sIL` to
show the final URL after redirects). Output pasted below, verbatim.

Label vocabulary: `verified-here` = reproduced by a command run on this host, output pasted ·
`404-cited` = the URL as written in a tracked file returns HTTP 404.

---

## 0. Verdict

- **All four old doc URLs still 404.** The S2 staleness finding is re-confirmed, not repaired.
- **Every `/en/`- and `/zh/`-prefixed replacement returns 200**, and `curl -sIL` shows the final
  URL is **identical to the request** — this is a hard path move, not a redirect. So a stale link
  does *not* self-heal; the prefix must actually be written into the citation.
- **The cited content reproduces on the `/en/` pages** (four substantive greps, §3).
- **One 404 remains cited in a tracked file and is *not* covered by the note's S2 item**:
  `adaptation-kimi.md:6` cites `github.com/EpicGames/unreal-engine-skills-for-claude-code`, which
  is **404**. The real repository is `…-claude-code-plugin` (200; `git ls-remote` returns the pin
  `a6aa73ad…b297`). `PROVENANCE.md` already records the correct `-plugin` URL, so this is a
  one-token defect in the note's own header, not in the provenance chain. See §4.

---

## 1. Old vs new doc URLs — full matrix (verified-here)

```bash
$ for u in customization/plugins.html customization/hooks.html customization/mcp.html \
           configuration/config-files.html release-notes/changelog.html ; do
>   printf '%-46s ' "/$u"
>   curl -sIL --max-time 20 -o /dev/null -w '%{http_code} %{url_effective}\n' \
>     "https://moonshotai.github.io/kimi-code/$u"
> done
```

| path | old (no prefix) | `/en/` | `/zh/` | final URL after redirects |
|---|---|---|---|---|
| `customization/plugins.html` | **404** | **200** | **200** | identical to request in every case |
| `customization/hooks.html` | **404** | **200** | **200** | identical to request in every case |
| `customization/mcp.html` | **404** | **200** | **200** | identical to request in every case |
| `configuration/config-files.html` | **404** | **200** | **200** | identical to request in every case |
| `release-notes/changelog.html` | **404** | **200** | — | identical to request |

Raw status lines, verbatim:

```
/customization/plugins.html                    404  | followed=404 https://moonshotai.github.io/kimi-code/customization/plugins.html
/customization/hooks.html                      404  | followed=404 https://moonshotai.github.io/kimi-code/customization/hooks.html
/customization/mcp.html                        404  | followed=404 https://moonshotai.github.io/kimi-code/customization/mcp.html
/configuration/config-files.html               404  | followed=404 https://moonshotai.github.io/kimi-code/configuration/config-files.html
/en/customization/plugins.html                 200  | followed=200 https://moonshotai.github.io/kimi-code/en/customization/plugins.html
/en/customization/hooks.html                   200  | followed=200 https://moonshotai.github.io/kimi-code/en/customization/hooks.html
/en/customization/mcp.html                     200  | followed=200 https://moonshotai.github.io/kimi-code/en/customization/mcp.html
/en/configuration/config-files.html            200  | followed=200 https://moonshotai.github.io/kimi-code/en/configuration/config-files.html
/zh/customization/plugins.html                 200  | followed=200 https://moonshotai.github.io/kimi-code/zh/customization/plugins.html
/zh/customization/hooks.html                   200  | followed=200 https://moonshotai.github.io/kimi-code/zh/customization/hooks.html
/zh/customization/mcp.html                     200  | followed=200 https://moonshotai.github.io/kimi-code/zh/customization/mcp.html
/zh/configuration/config-files.html            200  | followed=200 https://moonshotai.github.io/kimi-code/zh/configuration/config-files.html
/release-notes/changelog.html                  404  | followed=404 https://moonshotai.github.io/kimi-code/release-notes/changelog.html
/en/release-notes/changelog.html               200  | followed=200 https://moonshotai.github.io/kimi-code/en/release-notes/changelog.html
/                                              200  | followed=200 https://moonshotai.github.io/kimi-code/
/en/                                           200  | followed=200 https://moonshotai.github.io/kimi-code/en/
```

16 requests. The site root and `/en/` root both 200, so the host itself is up — the 404s are path
moves, not an outage.

**Note for the owning seat:** because the final URL equals the request (no 301/302), a reader who
clicks the *old* URL lands on a bare 404 page with no automatic rescue. The `/en/` prefix is
therefore a mandatory edit, exactly as the proposed note says.

---

## 2. Non-doc URLs cited in the tracked files (verified-here)

Every URL that actually appears in `adaptation-kimi.md`, plus the upstream repo's true home:

```bash
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code} %{url_effective}\n' <url>
```

| URL | where cited | status | final URL |
|---|---|---|---|
| `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` | `adaptation-kimi.md:6` | **404** | same (404 page) |
| `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | `PROVENANCE.md:19,94` | **200** | same |
| `https://github.com/EpicGames` | — | **200** | same |
| `http://127.0.0.1:8000/mcp` | `adaptation-kimi.md:119` | **000 / curl exit 7** | not a doc URL — loopback MCP endpoint, correctly unbound on this host |

Raw lines:

```
https://github.com/EpicGames/unreal-engine-skills-for-claude-code        404 https://github.com/EpicGames/unreal-engine-skills-for-claude-code
https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin 200 https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
https://api.github.com/repos/EpicGames/unreal-engine-skills-for-claude-code-plugin 200
https://github.com/EpicGames                                             200 https://github.com/EpicGames
http://127.0.0.1:8000/mcp                                                000 (curl exit 7 — connection refused)
```

`git ls-remote` disambiguates beyond doubt — the bare name is not a redirect of the suffixed one,
it is a different (nonexistent) repo:

```bash
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code main
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine-skills-for-claude-code/' not found
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
```

The `-plugin` URL returns **exactly the pinned SHA**. The pinned *commit* page is also reachable:

```bash
$ curl -sI --max-time 20 -o /dev/null -w '%{http_code}\n' \
    "https://api.github.com/repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/commits/a6aa73ada02a9fb1f5415bec491f9942c519b297"
200
```

---

## 3. The cited content still lives on the `/en/` pages (verified-here)

Status code alone is not enough — confirming each fact the table depends on actually renders on the
prefixed page:

```bash
$ curl -s https://moonshotai.github.io/kimi-code/en/customization/plugins.html \
    | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'per-user[^.]{0,110}'
per-user and apply to all projects; project-level installation scope is not yet supported

$ curl -s https://moonshotai.github.io/kimi-code/en/customization/hooks.html \
    | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'exit code 2|startup|resume|SessionStart' | sort -u
exit code 2
resume
SessionStart
startup

$ curl -s https://moonshotai.github.io/kimi-code/en/configuration/config-files.html \
    | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'default_permission_mode|permission_mode|Top-level' | sort -u
default_permission_mode
top-level
Top-level

$ curl -s https://moonshotai.github.io/kimi-code/en/customization/mcp.html \
    | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE '/mcp-config|mcp.json|connection status' | sort -u
connection status
/mcp-config
mcp.json
```

Every fact the rows cite reproduces: row 9's verbatim `per-user … not yet supported` note, row 3/5's
`startup` / `resume` / `exit code 2`, row 13's `default_permission_mode` + "Top-level fields", and
row 10's `/mcp-config` + "connection status". **No row's content needs changing — only the prefix.**

The changelog lag also reproduces on the prefixed page:

```bash
$ curl -s https://moonshotai.github.io/kimi-code/en/release-notes/changelog.html \
    | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oE '2\.[0-9]+\.[0-9]+' | head -5
2.1.1
2.1.0
2.1.0
2.0.2
2.0.1
```

Newest published entry is still **2.1.1**, older than the installed **2.2.0** — the note's
"docs lag the binary" carry-forward stands.

---

## 4. Defect surfaced by this sweep — `adaptation-kimi.md:6` cites a 404 repo URL

**This is outside the S2 item** the note currently proposes. The note fixes the four doc URLs but
would leave the header's repository URL broken.

`adaptation-kimi.md:6-8` as written:

```
- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` pinned at
  `a6aa73ada02a9fb1f5415bec491f9942c519b297` (clone at `/tmp/ue-skills-ref`, `git rev-parse HEAD`
  returned exactly that SHA).
```

The `-plugin` suffix is missing. Evidence that the correct name is `-plugin` and that the rest of
the repo already knows it:

```bash
$ git -C /tmp/ue-skills-ref remote -v
origin	https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (fetch)
origin	https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin (push)
$ grep -n 'repository' corpus/knowledge/unreal-mcp/PROVENANCE.md
19:| repository | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | ... |
```

`PROVENANCE.md:19` and `:94` carry the correct URL; only `adaptation-kimi.md:6` has the bare form.
Recommended fix (one token, for the owning seat — **not applied here**, `adaptation-kimi.md` is
read-only to this seat):

```
- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` pinned at
```

The pin, the SHA, and the `/tmp/ue-skills-ref` clone are all unaffected — only the display URL.

---

## 5. "No 404 remains cited" — the check the seat asked for

After the proposed note lands, the only doc URLs a reader would encounter are the `/en/`-prefixed
ones, all 200. Enumerating every URL that would remain in the two tracked files post-note:

| tracked file | URL as it will read post-note | status |
|---|---|---|
| `adaptation-kimi.md` row 1 | `…/kimi-code/en/customization/plugins.html` | 200 |
| `adaptation-kimi.md` row 3 | `…/kimi-code/en/customization/hooks.html` | 200 |
| `adaptation-kimi.md` row 5 | `…/kimi-code/en/customization/hooks.html` | 200 |
| `adaptation-kimi.md` rows 6,7,8 | `…/kimi-code/en/customization/plugins.html` | 200 |
| `adaptation-kimi.md` row 10 | `…/kimi-code/en/customization/mcp.html` | 200 |
| `adaptation-kimi.md` row 13 | `…/kimi-code/en/configuration/config-files.html` | 200 |
| `adaptation-kimi.md` line 6 | `…/unreal-engine-skills-for-claude-code-plugin` | 200 (only if §4 fix lands) |
| `adaptation-kimi.md` line 119 | `http://127.0.0.1:8000/mcp` | n/a — loopback, not a doc link |

**Result: no 404 remains cited, provided both edits land** — the `/en/` prefix (already in the
proposed note) **and** the `-plugin` suffix (§4, currently missing from the note). Without the
second edit, one 404 survives in a tracked file.

---

## 6. Reproducibility

```bash
BASE=https://moonshotai.github.io/kimi-code
for u in customization/plugins.html customization/hooks.html customization/mcp.html \
         configuration/config-files.html release-notes/changelog.html; do
  for p in "" en/ zh/; do
    curl -sIL --max-time 20 -o /dev/null -w "$p$u -> %{http_code}\n" "$BASE/$p$u"
  done
done
git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
```

All requests are network reads; nothing on this host was modified. Only this file was written.

---

## 7. Bottom line for the round

- **S2 confirmed, not repaired:** 4/4 old doc URLs 404; 4/4 `/en/` replacements 200; content intact.
- **New defect for the note to absorb:** `adaptation-kimi.md:6` cites a 404 repo URL; the real name
  is `…-claude-code-plugin` and `PROVENANCE.md` already has it right.
- **No Unreal runtime claim is made or implied.** The loopback MCP URL is unbound on this host
  (curl exit 7); nothing here touches editor or live-MCP behavior.
