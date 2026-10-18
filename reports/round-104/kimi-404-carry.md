# SEAT-47 KIMI-404-CARRY — `adaptation-kimi.md:6` 404 repo URL, re-verified

**Round:** r104 · **Lane:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · **Seat:** SEAT-47
KIMI-404-CARRY · **HEAD:** `88c3b2ca70fc83ec47a931d7b6dcff85a111c04e` · **Receipt:**
`2026-10-18T19:17:18Z`

**Scope (declared):** re-verify the r103 defect at `adaptation-kimi.md:6` (does the bare repo URL
still 404? does the `-plugin`-suffixed URL resolve 200?) and draft the exact one-line fix text for a
future fold. **`adaptation-kimi.md` was NOT edited** — read-only to this seat. Only this file was
written.

Target under test: `corpus/knowledge/unreal-mcp/adaptation-kimi.md`, 506 lines, sha256
`084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879` — clean vs HEAD
(`git status --porcelain` empty; `git show HEAD:… | sha256sum` returns the same digest).

---

## 1. Verdict

**The r103 finding is re-confirmed on today's HEAD, unchanged in every particular.**

- The bare URL is **still 404** — it is a hard 404, not a redirect, and not a transient.
- The `-plugin`-suffixed URL is **still 200**, and `git ls-remote` against it still returns the
  pinned SHA `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
- The defect is **one token in one line**, and the fix is mechanical.
- **No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor is not
  installed on this host; nothing here touches the editor or live-MCP behavior.

---

## 2. The re-verification (verified-here, output pasted verbatim)

### 2.1 HTTP — bare vs `-plugin`

```bash
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code
404
$ curl -sL --max-time 20 -o /dev/null -w 'final=%{url_effective} code=%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code
final=https://github.com/EpicGames/unreal-engine-skills-for-claude-code code=404
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
200
$ curl -sL --max-time 20 -o /dev/null -w 'final=%{url_effective} code=%{http_code}\n' \
    https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
final=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin code=200
```

`curl -sL` shows `url_effective` **identical to the request** in both cases. So this is a **hard
path miss**, not a rename redirect that a reader would silently follow to the right page. A reader
clicking `:6` lands on GitHub's 404 page and stays there.

### 2.2 GitHub API — the authoritative existence check

```bash
$ curl -s --max-time 20 -o /dev/null -w 'api bare=%{http_code}\n' \
    https://api.github.com/repos/EpicGames/unreal-engine-skills-for-claude-code
api bare=404
$ curl -s --max-time 20 -o /dev/null -w 'api plugin=%{http_code}\n' \
    https://api.github.com/repos/EpicGames/unreal-engine-skills-for-claude-code-plugin
api plugin=200
```

The API 404 is the decisive datum: unlike the web 404, it cannot be a login wall, a soft redirect,
or an anti-scrape interstitial. The repository `EpicGames/unreal-engine-skills-for-claude-code`
does not exist. Case does not rescue it either:

```bash
$ for u in unreal-engine-skills-for-claude-code unreal-engine-skills-for-claude-code-plugin; do
>   for c in EpicGames epicgames; do
>     printf '%s/%s -> ' "$c" "$u"; curl -s --max-time 15 -o /dev/null -w '%{http_code}\n' "https://api.github.com/repos/$c/$u"
>   done
> done
EpicGames/unreal-engine-skills-for-claude-code -> 404
epicgames/unreal-engine-skills-for-claude-code -> 404
EpicGames/unreal-engine-skills-for-claude-code-plugin -> 200
epicgames/unreal-engine-skills-for-claude-code-plugin -> 200
```

GitHub slugs are case-insensitive, so the two owner spellings are the same repo; the discriminator
is **solely** the `-plugin` suffix.

### 2.3 Git protocol — and the pin is still resolvable through the correct slug

```bash
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code main
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine-skills-for-claude-code/' not found
exit=128
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
exit=0
```

The exit-128 clone failure on the bare slug matters beyond the link: **the URL as written at `:6` is
not merely a broken display link, it is not cloneable.** Anyone following the header literally to
reproduce the r101 clone (`git clone <url> /tmp/ue-skills-ref`, the exact command at
`PROVENANCE.md:94`) gets "Repository not found".

### 2.4 The pin chain is intact — the correct slug still serves the pinned commit

```bash
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin refs/heads/main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
$ grep -n '^PIN=' corpus/knowledge/unreal-mcp/gate/run_gate.sh
31:PIN=a6aa73ada02a9fb1f5415bec491f9942c519b297
```

`refs/heads/main` on the `-plugin` repo **is** the pin that `run_gate.sh:31` and `PROVENANCE.md`
anchor to. So correcting the display URL does not weaken any claim — it restores the link between
the header and the pin the rest of the subtree already uses. `run_gate.sh:32` carries
`REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` — already correct.

---

## 3. Scoping — exactly which occurrences are defective

A `git grep` for the bare slug finds it in many places. **Only one of them is a defect.** The
distinction is **repo slug vs. plugin manifest name**, and it is load-bearing — a blanket
`sed`-style replace would corrupt four legitimate citation classes.

```bash
$ cat corpus/knowledge/unreal-mcp/upstream/.claude-plugin/plugin.json
{
  "name": "unreal-engine-skills-for-claude-code",
  "version": "3.1.1",
  ...
}
```

The plugin's own manifest declares its **name** as the bare form. That name is a machine key used in
Claude Code's `/plugin install <name>@<marketplace>` syntax and in plugin ids — it is *correct* as
written and must not gain a `-plugin` suffix.

| occurrence | what it is | verdict |
|---|---|---|
| `adaptation-kimi.md:6` | **repo URL** — `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` | **DEFECT — the only one** |
| `adaptation-kimi.md:1` | file title, names the plugin | correct (plugin name) |
| `adaptation-kimi.md:486,490,494,496` | the r103 note's own evidence block, quoting the failing probe verbatim | **correct as-is — must not be touched** |
| `upstream/.claude-plugin/plugin.json:2` | the actual manifest `"name"` field | correct (plugin name) |
| `upstream/README.md:39,55,64` | `/plugin install <name>@claude-plugins-official`, settings key, Installed-tab label | correct (plugin name) |
| `README.md:146` | "plugin `unreal-engine-skills-for-claude-code`, version `3.1.1`" | correct (plugin name) |
| `executability/sequencer.md:53` | "plugin `unreal-engine-skills-for-claude-code` v3.1.1" | correct (plugin name) |
| `executability/scripting-programmatic.md:71` | quotes the manifest `"name"` field | correct (plugin name) |
| `PROVENANCE.md:1,19,94`, `gate/run_gate.sh:32`, `gate/README.md:58`, `README.md:78,91` | already the `-plugin` form | correct (already fixed) |

**The `:486/:490/:494/:496` rows are the trap.** Those lines are inside the dated r103 correction
note and are the *verbatim pasted output* of the failing probe — they are the falsification record
for this very defect. Rewriting them to the working URL would destroy the evidence that the defect
existed and make the note self-contradicting ("repository as `<url>`, which is **404**" with a URL
that returns 200). **A future fold must fix `:6` only and leave the note's quotes byte-identical.**

---

## 4. The exact one-line fix text (drafted, NOT applied)

Line 6 as it reads today (`sed -n '6p'`, `cat -A` confirms no trailing whitespace beyond the
newline):

```
- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` pinned at
```

Line 6 as it should read:

```
- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` pinned at
```

Properties of this edit, measured rather than assumed:

```bash
$ python3 - <<'PY'
p='corpus/knowledge/unreal-mcp/adaptation-kimi.md'
old='`https://github.com/EpicGames/unreal-engine-skills-for-claude-code` pinned at'
new='`https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` pinned at'
s=open(p,encoding='utf-8').read()
print('occurrences of old string:', s.count(old))
print('occurrences of new string:', s.count(new))
print('byte delta:', len(new.encode())-len(old.encode()))
PY
occurrences of old string: 1
occurrences of new string: 0
byte delta: 7
```

- **Unique** — the search string `…-claude-code\` pinned at` matches exactly once in the file, so
  the edit is unambiguous; no `replace_all` needed and none should be used.
- **+7 bytes** (`-plugin`), one line, one token, no line-count change (506 lines before and after).
- The distinguishing context is the trailing `` ` pinned at `` — including it in the search string is
  what keeps the edit off `:1` and off the `:486`-block quotes.
- Only lines 6–8 form the header paragraph; lines 7–8 (the pin SHA and the `/tmp/ue-skills-ref`
  clone note) are **unchanged and still accurate**.

Suggested edit operation for the owning seat (either a further dated note, or a declared header
repair — `:6` is above the r103 heading, so it belongs to whoever owns the r101 record):

```bash
# from the lane root, by the seat that owns the header:
#   old: https://github.com/EpicGames/unreal-engine-skills-for-claude-code` pinned at
#   new: https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` pinned at
```

---

## 5. What is NOT claimed

- **No repair was made.** `adaptation-kimi.md` is read-only to this seat and its sha256 is unchanged
  (`084a34cd…de8c879`, matching `git show HEAD:…`). The fix in §4 is a draft for a future fold.
- **No Unreal runtime claim.** Unreal Editor is not installed on this host; the `:6` URL is a public
  GitHub path, and resolving it says nothing about the editor, the plugin's runtime behavior, or the
  loopback MCP endpoint.
- **No claim that the r103 note was wrong.** It diagnosed this correctly and deliberately left it
  uncorrected; this file re-confirms its diagnosis on a later HEAD rather than revising it.
- **No claim about network durability.** All of §2 is a network read at `2026-10-18T19:17:18Z`. A
  GitHub-side rename could change any of these codes; the reproducibility block below is the re-run
  recipe.

---

## 6. Reproducibility

```bash
BASE=https://github.com/EpicGames
for u in unreal-engine-skills-for-claude-code unreal-engine-skills-for-claude-code-plugin; do
  printf 'web  %s -> ' "$u"; curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' "$BASE/$u"
  printf 'api  %s -> ' "$u"; curl -s   --max-time 20 -o /dev/null -w '%{http_code}\n' "https://api.github.com/repos/EpicGames/$u"
  printf 'git  %s -> ' "$u"; git ls-remote "$BASE/$u" refs/heads/main 2>&1 | tail -1
done
git ls-remote "$BASE/unreal-engine-skills-for-claude-code-plugin" refs/heads/main   # expect a6aa73a…
sed -n '6p' corpus/knowledge/unreal-mcp/adaptation-kimi.md
sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md   # expect 084a34cd…de8c879 (unmodified)
```

All commands are network or read-only; nothing on this host was modified except this report file.

---

## 7. Bottom line for the round

- **404 re-confirmed, unchanged:** bare slug 404 on web, API, and `git ls-remote` (exit 128);
  `-plugin` slug 200 on all three, and its `main` still carries the pin `a6aa73a…`.
- **Hard miss, not a redirect** (`url_effective` == request in both directions) — a reader clicking
  `:6` gets a 404 page, and the literal clone command in `PROVENANCE.md:94` fails if fed `:6`'s URL.
- **Exactly one defective occurrence:** `adaptation-kimi.md:6`. `:1`, `:486–496`, the upstream
  manifest `name`, and the three prose "plugin `<name>`" citations are all the *plugin name*, not the
  repo slug, and must not be touched.
- **Fix drafted, not applied:** one token, `-plugin`, +7 bytes, unique match, 506 → 506 lines. See §4.
- **No Unreal runtime claim made or implied.**
