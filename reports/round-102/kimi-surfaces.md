# r102 SEAT-62 — Kimi CLI surface re-probe (freshness audit of `adaptation-kimi.md`)

Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · HEAD `2c99b7b` · probe date
**2026-10-18** (UTC receipt `2026-10-18T17:42:33Z`).

Scope: re-probe every Kimi-side surface that `corpus/knowledge/unreal-mcp/adaptation-kimi.md`
cites, and decide whether that table needs a freshness note under its own §5 invalidation rule.
`adaptation-kimi.md` was **read only** — no write to it, no write to any `corpus/` path. The only
file this seat writes is this report.

Label vocabulary: `verified-here` = reproduced by a command run on this host, output pasted below ·
`stale` = the citation as written no longer resolves.

---

## 0. Verdict

**No full invalidation.** The invalidation rule (§5) is scoped to pointers of the form
"`kimi` binary strings line N", valid only for BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`
(v2.2.0). The installed binary is **byte-for-byte the same build**: version `2.2.0`, BuildID
`5e67bdf95c7646325b62decd0ca8d375d325ea19`, and every spot-checked strings-line pointer lands on
exactly the cited text. So the table's binary-anchored rows need **no** note on that ground.

**But the table does need a freshness note**, because three non-binary citations drifted:

| # | Citation as written | State | What it is now |
|---|---|---|---|
| S1 | row 2: `~/.kimi-code/config.toml:2932-2937` = "live `[[hooks]]` precedent" | **stale** | that range is a `[models.*]` table; the file's only `[[hooks]]` is at line **3219**, `event = "Notification"` |
| S2 | rows 1,3,5,6,7,9,10,13: `moonshotai.github.io/kimi-code/{customization,configuration}/*.html` | **stale** | all return **HTTP 404**; the site now serves locale-prefixed pages (`/en/…`, `/zh/…`), which return 200 and still carry the cited content |
| S3 | §4.2, §3.2, §3.3: commands run against `/tmp/ue-skills-ref` and `/tmp/r101work` | **volatile, currently live** | `/tmp/ue-skills-ref` still exists and its `HEAD` is still the pin; but `/tmp` is not durable, and the vendored `corpus/knowledge/unreal-mcp/upstream/` copy is the reproducible substitute |

Proposed note text (for the owning seat to land in `adaptation-kimi.md`; **not applied here** —
see §4).

---

## 1. Binary identity — the anchor (verified-here)

```bash
$ kimi --version
2.2.0
$ sha256sum /home/vgpnk/.kimi-code/bin/kimi
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  kimi
$ readelf -n /home/vgpnk/.kimi-code/bin/kimi | grep -i build-id
    Build ID: 5e67bdf95c7646325b62decd0ca8d375d325ea19
$ stat -c '%s %y' /home/vgpnk/.kimi-code/bin/kimi
191892672 2026-10-14 19:58:50.344019494 -0300
```

Both cited identifiers — `2.2.0` and BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`
(`adaptation-kimi.md:9-10`) — reproduce exactly. The binary has not been rebuilt or upgraded since
the r101 probe (`file` also reports `BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19`).

**New datum not in the table:** the binary's own SHA-256 is
`8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af`. BuildID alone is the
documented anchor; the sha256 is a stronger one and is worth recording for the next re-probe.

Strings were re-extracted fresh (not reused from r101):

```bash
$ strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /tmp/kimi_strings_r102.txt
$ wc -l /tmp/kimi_strings_r102.txt
2644877 /tmp/kimi_strings_r102.txt
$ sha256sum /tmp/kimi_strings_r102.txt
380092949dc22e60778bd5dce77b5cbb9912ff87d662db3cace59e0e115e225d  /tmp/kimi_strings_r102.txt
```

---

## 2. Pointer spot-check (verified-here)

Every strings-line pointer the table cites was re-resolved against the fresh extraction. Line
numbers match the cited ones **exactly** — the invalidation rule is not triggered.

### §3.4 — manifest constants (cited `1832505` / `1832506`)

```bash
$ grep -n 'KIMI_PLUGIN_ROOT_PATH\|KIMI_PLUGIN_DIR_PATH' /tmp/kimi_strings_r102.txt
1832500:var KIMI_PLUGIN_ROOT_PATH, KIMI_PLUGIN_DIR_PATH, PLUGIN_SYSTEM_PROMPT_MAX_BYTES, UNSUPPORTED_RUNTIME_FIELDS;
1832505:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
1832506:	KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json";
```

Lines 1832505 and 1832506 are byte-identical to the quoted pair. Row 1/8's manifest search order
(`kimi.plugin.json` first, then `.kimi-plugin/plugin.json`) still holds.

### §3.5 — `resolveMcpJsonPaths` (cited `1743845`)

```bash
$ grep -n 'async function resolveMcpJsonPaths' /tmp/kimi_strings_r102.txt
1743845:async function resolveMcpJsonPaths(input) {
```

Exact. Row 11's three-layer resolution (`$KIMI_CODE_HOME/mcp.json`, `<git-root>/.mcp.json`,
`<cwd>/.kimi-code/mcp.json`) is unchanged, including the `findGitWorkTree` project-root rule that
makes the editor-written `.mcp.json` Kimi-native.

### §4 — all five NONE-FOUND greps still return 0 (verified-here)

```bash
$ grep -c enabledPlugins /tmp/kimi_strings_r102.txt        # 0
$ grep -c enabledPlugins ~/.kimi-code/config.toml          # 0
$ grep -c 'settings\.json' /tmp/kimi_strings_r102.txt      # 0
$ grep -o '\.claude/settings[a-z.]*' /tmp/kimi_strings_r102.txt | sort -u   # (empty)
$ grep -c CLAUDE_PLUGIN_ROOT /tmp/kimi_strings_r102.txt    # 0
$ grep -c additionalContext /tmp/kimi_strings_r102.txt     # 0
$ grep -o 'CLAUDE_[A-Z_]*' /tmp/kimi_strings_r102.txt | sort -u
CLAUDE_FAMILY_WORD_RE
CLAUDE_THINKING_VISION_TOOL_PREFIXES
CLAUDE_VISION_TOOL_PREFIXES
```

§4.1's supporting detail also reproduces: the only `.claude*` paths the binary knows are
`.claude/AGENTS.md`, `.claude/CLAUDE.md`, `.claude/skills`, `.claude/commands` and `.claude.json`
(3 hits) — import sources, not live config.

§4.2 was re-run against the **vendored** copy rather than `/tmp` (see S3):

```bash
$ cd corpus/knowledge/unreal-mcp
$ grep -o "GenerateClientConfig [A-Za-z]*" upstream/skills/unreal-mcp/references/*.md | sort -u
upstream/skills/unreal-mcp/references/operations.md:GenerateClientConfig ClaudeCode
upstream/skills/unreal-mcp/references/setup.md:GenerateClientConfig ClaudeCode
$ grep -rn "Kimi\|kimi" upstream/ --include=*.md --include=*.json | head; echo "exit=$?"
exit=1
```

Same verdict: the only target is `ClaudeCode`; the vendored plugin has zero Kimi awareness.

### Row 4 — the load-bearing schema claim (verified-here)

```bash
$ grep -n 'HookSpecificOutputSchema\|HookJsonOutputSchema' /tmp/kimi_strings_r102.txt
1841209:		const output = HookJsonOutputSchema.safeParse(parsed);
1841245:var DEFAULT_TIMEOUT_SECONDS, KILL_GRACE_MS$1, OptionalStringSchema, HookSpecificOutputSchema, HookJsonOutputSchema;
1841256:	HookSpecificOutputSchema = preprocess((value) => isRecord$15(value) ? value : void 0, looseObject({
1841261:	HookJsonOutputSchema = looseObject({
1841263:		hookSpecificOutput: HookSpecificOutputSchema
$ grep -c 'hookEventName' /tmp/kimi_strings_r102.txt
1
$ grep -n 'hookEventName' /tmp/kimi_strings_r102.txt
1841291:		hookEventName: event,
```

The §2 row-4 quote is still exact, and its sharpest sub-claim — "the binary contains exactly one
`hookEventName` occurrence, at the point where the CLI builds the *input* payload" — reproduces at
**count = 1**. Row 4's `NONE-FOUND` for `additionalContext` is therefore still the table's
load-bearing adaptation gap, unchanged.

### Rows 2/3 — SessionStart source (verified-here, live probe re-run)

Re-ran the §3.1 probe shape against a throwaway `KIMI_CODE_HOME` seeded from the operator's real
config (so a model resolved) plus an appended `SessionStart` hook:

```bash
$ cat >> /tmp/r102probe/home/config.toml <<'EOF'

[[hooks]]
event = "SessionStart"
command = "cat > /tmp/r102probe/ss_stdin.json"
EOF
$ cd /tmp/r102probe/fakeproj && KIMI_CODE_HOME=/tmp/r102probe/home timeout 90 kimi -p "reply with the single word OK"
kimi version 2.2.0
error: failed to run prompt: provider managed:kimi-code has no credential configured
$ cat /tmp/r102probe/ss_stdin.json
{"hook_event_name":"SessionStart","session_id":"session_6dec13ca-d240-465f-8427-93bdfd7e4070","cwd":"/tmp/r102probe/fakeproj","client_type":"kimi_code_cli","source":"startup","model":"kimi-code/kimi-for-coding","profile":"agent"}
```

The `SessionStart` payload shape, the stdin-JSON transport, and `"source":"startup"` all reproduce
— the cited `source` vocabulary (`startup` / `resume`, no `clear`) is unchanged. Note the throwaway
home had no credential, so the model turn failed; the **hook still fired first**, which is all this
check needs (row 3's claim is about the payload, not the answer). Independently corroborated in the
binary: the session-create path calls `announceCreated({ …, source: "startup" })`
(`/tmp/kimi_strings_r102.txt:1805854`) and there is no `source: "clear"` at a session-start call
site.

### Row 7 / row 11 / row 15 — file pointers (verified-here)

```bash
$ wc -l ~/.kimi-code/plugins/installed.json     # 13   (row 7 cites :1-13)
$ wc -l ~/.kimi-code/mcp.json                   # 11   (row 11 cites :1-11)
$ ls ~/.kimi-code/skills/                       # godspeed reverse-engineer-anything shokunin ufo wwkd
$ ls ~/.agents/skills/                          # godspeed omarchy reverse-engineer-anything shokunin swarm tower ufo
```

Both cited line ranges still bracket the whole file, and both row-15 skill directories exist with
the cited shape.

---

## 3. What drifted

### S1 — row 2's `config.toml:2932-2937` (stale)

```bash
$ sed -n '2932,2937p' ~/.kimi-code/config.toml
reasoning_key = "reasoning_content"
support_efforts = [ "low", "medium", "high" ]

[models."opencode-go-7/longcat-2.0"]
provider = "opencode-go-7"
model = "longcat-2.0"
$ wc -l ~/.kimi-code/config.toml
3251
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
3219:[[hooks]]
$ sed -n '3219,3224p' ~/.kimi-code/config.toml
[[hooks]]
event = "Notification"
matcher = "task\\.completed"
command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"
timeout = 5
```

The citation is void as written, but its **substance survives**: a live `[[hooks]]` precedent does
exist, at line 3219, with the same field vocabulary (`event` / `matcher` / `command` / `timeout`)
row 2 depends on. Only the event differs (`Notification` vs `SessionStart`). This is a moved-line
staleness in a file the operator edits continuously — the config file's mtime is the probe day
itself, and it grew from 2 9xx to 3251 lines since r101.

Row 13's `config.toml:1` is **not** stale — line 1 is still `default_permission_mode = "auto"`.

### S2 — documentation URLs (stale)

```bash
$ for u in customization/plugins.html customization/hooks.html customization/mcp.html configuration/config-files.html; do
>   printf '%s -> ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' --max-time 12 "https://moonshotai.github.io/kimi-code/$u"; done
customization/plugins.html -> 404
customization/hooks.html -> 404
customization/mcp.html -> 404
configuration/config-files.html -> 404
```

All four of the site's root-relative paths now 404. The site serves locale-prefixed pages:

```bash
$ curl -s -o /dev/null -w '%{http_code}\n' https://moonshotai.github.io/kimi-code/en/customization/plugins.html
200
$ # …and 200 for en/customization/{hooks,mcp}.html, en/configuration/config-files.html, and the zh/ equivalents
```

**The cited content still holds** — only the URL prefix moved. Re-checked the two substantive
doc quotations:

```bash
$ curl -s https://moonshotai.github.io/kimi-code/en/customization/plugins.html | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'per-user[^.]{0,120}'
per-user and apply to all projects; project-level installation scope is not yet supported
$ curl -s https://moonshotai.github.io/kimi-code/en/customization/hooks.html | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'startup|resume|exit code 2|block' | sort -u | head
block
exit code 2
resume
source , model , profile …
startup
```

Row 9's verbatim docs quotation and row 3/5's `startup`/`resume` + `exit code 2` facts both
reproduce on the `/en/` page. No row needs its *content* changed.

**Separate observation worth carrying forward:** the published changelog's newest entry is
**2.1.1**, older than the installed **2.2.0** binary:

```bash
$ curl -s https://moonshotai.github.io/kimi-code/en/release-notes/changelog.html | grep -c '2\.2\.0'
0
```

So the docs lag the shipped CLI. For CLI-surface claims the binary is the source of truth, which is
already the table's implicit posture (§5's invalidation rule is binary-scoped). This strengthens,
not weakens, the table's design.

### S3 — `/tmp` working trees (volatile)

```bash
$ ls -d /tmp/ue-skills-ref && git -C /tmp/ue-skills-ref rev-parse HEAD
/tmp/ue-skills-ref
a6aa73ada02a9fb1f5415bec491f9942c519b297
```

Both `/tmp/ue-skills-ref` (used by §3.2, §3.3, §4.2) and `/tmp/r101work` (used by §3.1-§3.3) are
`/tmp` paths. `/tmp/ue-skills-ref` happens to still exist and still holds the pin, so §4.2 is
currently re-runnable as written; but a reboot or `tmpfiles` sweep removes it, and the table
already ships the durable substitute — the byte-identical `upstream/` copy, whose pin is proven in
`PROVENANCE.md`. Re-ran §4.2 against that copy above and got the same answer.

Spot-confirmed the vendored copy is still the pinned content:

```bash
$ cd corpus/knowledge/unreal-mcp
$ sha256sum upstream/hooks/hooks.json upstream/README.md
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  upstream/hooks/hooks.json
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  upstream/README.md
```

Both match the manifest prefixes recorded in the subtree README (`259124f0…b5ebdc0c`,
`483693ad…46b40e`).

---

## 4. Proposed freshness note (NOT applied — `adaptation-kimi.md` is read-only to this seat)

Text for the owning seat to land. It is a **dated correction note**, not a rewrite: no historical
claim is altered, and the note names exactly which citation is void and what replaced it.

```md
### Freshness re-probe — 2026-10-18 (r102)

Re-run before reuse. The binary anchor is **intact**, so §5's invalidation rule is *not* triggered:

- `kimi --version` = `2.2.0`; BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`; binary sha256
  `8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af` (unchanged since r101).
- Every "binary strings line N" pointer in §3.4 / §3.5 still resolves to the cited text, and all
  five §4 NONE-FOUND greps still return 0. Row 4's "exactly one `hookEventName`" still holds
  (count = 1).

Two non-binary citations are **void as written**:

1. §Row 2 cites `~/.kimi-code/config.toml:2932-2937` as the live `[[hooks]]` precedent. That range
   is now a `[models.*]` table. The file's only `[[hooks]]` is at **line 3219**, and its event is
   `Notification`, not `SessionStart`. The precedent exists; the line number moved.
2. Every `moonshotai.github.io/kimi-code/{customization,configuration}/*.html` URL returns
   **HTTP 404**. The docs site now serves locale-prefixed pages — prefix `/en/` (or `/zh/`) to the
   same path, e.g. `…/kimi-code/en/customization/plugins.html` (200). The quoted content is
   unchanged; rows 3, 5, 6, 7, 9, 10 and 13 stand.

Carry-forward: the published changelog's newest entry is `2.1.1`, older than the installed `2.2.0`
binary, so the docs are a lagging source. Treat binary strings as the source of truth for CLI
surfaces — which is already §5's posture.

Live-editor posture unchanged: Unreal Editor is still not installed on this host, so every §6 item
remains `unproven-runtime` and no Unreal runtime claim is made here.
```

If the owning seat prefers a one-line variant, the minimal edit is: change the row-2 pointer to
`config.toml:3219` (or better, "`[[hooks]]` at the file's sole such block"), and prefix the doc
URLs with `/en/`. Both are mechanical conformance fixes; the dated note above is the
correction-note form if the table is treated as a historical artifact.

---

## 5. Bottom line for the table's users

- **No row's verdict changes.** All 15 rows keep their status class; the six `verified-here` rows
  (2, 3, 4, 8, 9, 11) are re-confirmed by this probe where they were re-run (rows 3 and 4 directly;
  rows 2, 8, 9, 11 via their binary/file pointers).
- **Yes, the table needs a freshness note** — for the two stale citations (S1, S2), not for the
  binary anchor.
- **`unproven-runtime` is untouched.** No Unreal Editor on this host; nothing in this report is a
  runtime claim about the editor or about live-MCP behavior.

## 6. Reproducibility

| Artifact | Path | Note |
|---|---|---|
| fresh strings dump | `/tmp/kimi_strings_r102.txt` | 2 644 877 lines, sha256 `380092949dc2…` |
| live-probe home | `/tmp/r102probe/home` | throwaway `KIMI_CODE_HOME`; operator config copied, never modified |
| probe project | `/tmp/r102probe/fakeproj` | synthetic cwd |
| hook receipt | `/tmp/r102probe/ss_stdin.json` | `source":"startup"` payload |

All `/tmp` paths are transient; re-derive with the commands in §1-§3.
