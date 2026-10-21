# r107-kimi-ver — KIMI-ADAPT-VER (round 107, 3D side-round)

Seat KEY=KIMI-ADAPT-VER. Job: independently verify every row of the Claude→Kimi mapping
(`corpus/knowledge/unreal-mcp/adaptation-kimi.md`) against THIS host — is the Kimi-side surface
real here, cited by config/file/binary? AGREE / DISAGREE per row. Draft only; orchestrator lands.

## Plan header (5 lines)
1. Fix the evidence anchors: `kimi --version` + BuildID/sha256 of the binary, and the pin of the
   vendored `upstream/` tree — a row is only checkable against a named anchor.
2. Re-run each row's *own* cited search independently (binary strings, config.toml, on-disk
   config/skill/plugin files); do not read any other seat's manifest or values.
3. For rows whose Kimi surface is a **file** (rows 1,2,7,8,11,13,15) require an on-disk path that
   exists here; for rows whose surface is a **binary constant/command** (3,4,5,6,9,10,12,14)
   require a strings hit or a documented zero.
4. Cross-check the row's *upstream* pointer too: does the cited upstream file:line exist at the
   vendored pin, and does it say what the row claims?
5. Emit AGREE/DISAGREE + a one-line falsifier per row; label [O]/[I]/[?]; UNPROVEN stays UNPROVEN.

## Axes (Godspeed)
- A1 independence — values re-derived from the wire/disk, never copied from another seat's file.
- A2 coverage — all 15 rows, both sides (Kimi surface + upstream pointer).
- A3 falsifiability — each verdict names the command that would flip it.
- A4 non-harm — writes only to `reports/round-107/` and `/var/tmp/r107-kimi-ver/`; no `corpus/` landing.

## 0. Status
- [O] 2026-10-19: header written as first action per round rules.
- [O] Anchors re-derived. Binary sha256 `8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af`,
  identical to the r103 record → §5's CLI-upgrade invalidation rule is **not** triggered; every
  "strings line N" pointer in the table is still live-addressable. Pin re-checked via `git ls-remote`
  → still `a6aa73a…`; all `upstream/…` pointers resolve.
- [O] All 15 rows independently re-run. **Result: 15/15 rows AGREE on substance; 0 rows DISAGREE
  on substance.** 4 citation-class defects (D1, D2, D4, plus the resolved header URL) and **2
  substantive amendments to row 11** (D3, D3b — both verified by live probes, §3). Row 11's "do
  nothing for MCP" holds for a trusted one-project-per-repo checkout and breaks otherwise.
- [O] Cross-checked against KIMI-ADAPT-LEAD's refreshed table (§3, after my probes): its trust-gate
  row, new row 17 and `"type"` promotion are **independently corroborated**; its one open §6
  register item (source-build path coincidence) is **falsified in the differ-case** by my Probe C.
- [O] Checked the UE docker pull between tasks (per seat instruction): pid 596299 still running,
  `/var/tmp/ue-pull.log` last line `991ca4b0b8b2: Pull complete`, `docker images | grep -ci unreal`
  → `0`. **No UE image present at time of writing**, so this seat makes no runtime claim and none
  is implied. The unlock verdict is the UNLOCK seat's to make.

## 1. Anchors

```
$ kimi --version
2.2.0
$ sha256sum /home/vgpnk/.kimi-code/bin/kimi
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  /home/vgpnk/.kimi-code/bin/kimi
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
```

Binary sha256 is **identical** to the r103 record → §5's invalidation rule (a CLI upgrade voids
every "strings line N" pointer) is **not** triggered this round. Pin unchanged → every
`upstream/…` pointer in the table is still anchored. Strings dump re-extracted this round to
`/var/tmp/r107-kimi-ver/kimi_strings.txt` (2644877 lines).

## 2. Method

For each row I re-ran **that row's own cited search**, on this host, without reading any other
seat's manifest or value. Two-sided: (a) does the *Kimi-side* surface exist here, (b) does the
*cited upstream* `file:line` exist at the vendored pin and say what the row claims.

Anchors used throughout:
- CLI: `kimi --version` → `2.2.0`; binary sha256 `8ee7405d…6111af` (**unchanged** from r103).
- Binary strings: `strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /var/tmp/r107-kimi-ver/kimi_strings.txt` (2644877 lines).
- Upstream pin: `git ls-remote <url> main` → `a6aa73ada02a9fb1f5415bec491f9942c519b297` **[O]** — still the pin; every `upstream/…` pointer below resolves.
- Docs: `https://moonshotai.github.io/kimi-code/en/…` (the `/en/` prefix is required; root-relative is 404 — independently re-confirmed, see §4 D4).

## 3. Per-row verdicts

| # | Kimi surface real here? | Upstream pointer resolves? | Verdict |
|---|---|---|---|
| 1 | yes | yes | **AGREE** |
| 2 | yes | yes | **AGREE on substance / DISAGREE on citation** (D1) |
| 3 | yes | yes | **AGREE** |
| 4 | yes | yes | **AGREE** |
| 5 | yes | yes | **AGREE** |
| 6 | yes | yes | **AGREE** |
| 7 | yes | yes | **AGREE** |
| 8 | yes | yes | **AGREE** |
| 9 | yes | yes | **AGREE** |
| 10 | yes | yes | **AGREE** |
| 11 | yes | yes | **AGREE with 2 missing conditions** (D3, D3b) |
| 12 | yes | yes | **AGREE** (D4 note) |
| 13 | yes | yes | **AGREE** |
| 14 | yes | n/a (negative) | **AGREE** |
| 15 | yes | yes | **AGREE** |

### Row 1 — `CLAUDE_PLUGIN_ROOT` → `KIMI_PLUGIN_ROOT` + `KIMI_CODE_HOME`
```bash
grep -c 'CLAUDE_PLUGIN_ROOT' $S          # 0            [O]
grep -c 'KIMI_PLUGIN_ROOT'  $S          # 10           [O]
grep -c 'KIMI_CODE_HOME'    $S          # 54           [O]
grep -n 'KIMI_PLUGIN_ROOT: pluginRoot' $S   # 1833038   [O]
```
Docs (`plugins.html` §Hooks in Plugins) state it verbatim: *"The hook process receives two extra
environment variables: `KIMI_CODE_HOME` and `KIMI_PLUGIN_ROOT` (the plugin root directory)."* **[O]**
Row 1's `upstream/hooks/hooks.json:10` resolves and carries the `CLAUDE_PLUGIN_ROOT` command line **[O]**.
**AGREE.** Falsifier: any nonzero `grep -c 'CLAUDE_PLUGIN_ROOT'`.

### Row 2 — `[[hooks]]` in `config.toml`, `event = "SessionStart"` — **pointer DISAGREE**
Live precedent exists, but **not at the cited line**:
```bash
grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml      # 3538      [O]
wc -l ~/.kimi-code/config.toml                        # 3570      [O]
sed -n '3538,3542p' ~/.kimi-code/config.toml          # event/matcher/command/timeout  [O]
```
Row 2 cites `:2932`; r103's correction note republished `:3290`; measured now **`:3538`**. r103
warned "a moving target — do not trust the number", and its own replacement number is now stale
too. Substance **AGREE** (the file's sole `[[hooks]]` block exists with the exact field vocabulary;
`hookDefSchema` in the binary also enumerates `"SessionStart"` **[O]**); citation **DISAGREE**.
**Correct citation:** "`~/.kimi-code/config.toml`, the file's sole `[[hooks]]` block — locate with
`grep -n '\[\[hooks\]\]'`; it was 2932 (r101) → 3290 (r103) → 3538 (r107), never a stable number."

### Row 3 — matcher is a regex over `source`; no `clear` source
I initially flagged a possible error: `grep -o 'source: "clear"' $S` returns **1 hit** at line
1949603. Inspected in context, it is a transcript entry source (`case "context.clear"` →
`source: "clear"`), **exactly the site the row itself names** — not a SessionStart source. Row holds.
```bash
grep -n 'source: "startup"\|source: "resume"\|source: "clear"' $S
# 1805854 source: "startup"   / 1805990 source: "resume"   / 1949603 source: "clear" (transcript)  [O]
grep -n 'function matches\$1' $S     # new RegExp(pattern).test(value)  → regex over a string  [O]
sed -n '1841527,1841532p' $S
#   async triggerSessionStart(source) {
#       await this.runner.trigger("SessionStart", { matcherValue: source, … })   [O]
```
The matcher's test value is the `source` string itself, and the only values the code passes are
`startup` / `resume` — so `startup|resume|clear` is, as the row says, harmless but partially dead
on Kimi. Docs event reference: `SessionStart` | matcher matches **"`startup` or `resume`"** **[O]** —
verbatim. **AGREE.**

### Row 4 — `additionalContext` is NONE-FOUND
```bash
grep -c 'additionalContext' $S   # 0   [O]
sed -n '1841256,1841264p' $S
#   HookSpecificOutputSchema = preprocess(..., looseObject({
#       message, permissionDecision, permissionDecisionReason }).optional());
#   HookJsonOutputSchema = looseObject({ message, hookSpecificOutput })        [O]
grep -c 'hookEventName' $S       # 1  (line 1841291, the INPUT build: `hookEventName: event`)  [O]
```
Schema has no `additionalContext`, and the row's claim that `hookEventName` exists only on the
*input* side is confirmed — exactly one occurrence, at `toHookInputData` **[O]**. **AGREE.** This is
the load-bearing row and it is correct.

### Row 5 — exit-code semantics 0 / 2 / other
```bash
grep -n 'function resultFromExitCode' $S   # 1841176  [O]
#   if (exitCode === 2) { action: "block", message = stderr.trim() }          [O]
#   const structured = exitCode === 0 ? structuredOutput(stdout) : void 0;    [O]
```
Docs return-value table: `0` allow / `2` block / other non-zero fail-open allow / timeout fail-open **[O]**.
Row 5's pointer `unreal-context.sh:47` is the hook's own `exit 0` (actual line **46**, off by one —
the `if [ -z … ]` is 44, `debug` 45, `exit 0` 46) **[O]**. Substance **AGREE**; the pointer is
off-by-one but still lands inside the same 3-line block. Falsifier: `exitCode === 2` absent.

### Row 6 — `/plugins install <github-url>`, `/plugins marketplace [source]`, marketplace env
```bash
grep -o 'if (sub === "marketplace")' $S          # present  [O]
grep -c 'KIMI_CODE_PLUGIN_MARKETPLACE_URL' $S    # 9        [O]
grep -n 'function resolveMarketplaceLocation' $S # 1834776  [O]
```
`resolvePluginInstallSource` returns any `http://`/`https://` source unchanged **[O]**; docs
document four GitHub URL forms and the env-var override **[O]**. **AGREE.**

### Row 7 — `/plugins` panel + subcommands
Binary dispatch chain (`grep -n 'if (sub === '` around 2092111) enumerates
`list`, `install`, `marketplace`, `info`, `mcp`, `enable`, `disable`, `remove`, `reload` **[O]**;
`installed.json` is present on disk **[O]**. Docs list the identical command set **[O]**. **AGREE.**

### Row 8 — `kimi.plugin.json` / `.kimi-plugin/plugin.json`
```bash
grep -o 'KIMI_PLUGIN_ROOT_PATH = "[^"]*"' $S   # = "kimi.plugin.json"        [O]
grep -o 'KIMI_PLUGIN_DIR_PATH = "[^"]*"'  $S   # = ".kimi-plugin/plugin.json" [O]
ls ~/.kimi-code/plugins/managed/kimi-webbridge/kimi.plugin.json   # exists   [O]
```
Docs confirm both locations and `kimi.plugin.json` precedence **[O]**. `pluginManifestSchema`
fields **[O]**: `name, version, description, keywords, author, homepage, license, skills, agents,
sessionStart, mcpServers, hooks, commands, interface, skillInstructions, systemPrompt` — matching
the row's "adds fields the Claude one has no counterpart for". **AGREE.**

### Row 9 — `enabledPlugins` NONE-FOUND; per-user only
```bash
grep -c 'enabledPlugins' $S        # 0   [O]
grep -c 'settings.json'  $S        # 0   [O]
```
Docs: *"Plugins are currently installed per-user and apply to all projects; project-level
installation scope is not yet supported."* **[O]** — the row's verbatim quotation reproduces
exactly. **AGREE.**

### Row 10 — `/mcp` + `/mcp-config`
Binary ACP command `{ name: "mcp", description: "Show MCP server status" }` **[O]**; builtin skill
`mcp-config` with pseudo-path `builtin://mcp-config` **[O]**. Docs: *"Run `/mcp-config` in the TUI
to interactively add, edit, or delete servers… Run `/mcp` to view the connection status of all
current servers."* **[O]** **AGREE.**

### Row 11 — Kimi reads project-root `.mcp.json` natively — **AGREE, with 2 missing conditions**
```bash
sed -n '1743845,1743853p' $S   # resolveMcpJsonPaths: user / projectRoot(<git-root>/.mcp.json) / project  [O]
```
Matches the row's quoted source exactly. **Two live probes** (throwaway `KIMI_CODE_HOME` + synthetic
git-rooted project; the operator's config untouched):

**Probe A — is the extra `"type"` key tolerated?** The table's caveat (a) said this is
`unproven-runtime`. It is now **PROVEN-HERE**:
```bash
printf '%s' '{"mcpServers":{"unreal-mcp":{"type":"http","url":"http://127.0.0.1:18000/mcp"}}}' \
  > /var/tmp/r107-kimi-ver/proj_mcp/.mcp.json
cd /var/tmp/r107-kimi-ver/proj_mcp && KIMI_CODE_HOME=$H KIMI_CODE_TRUST_WORKSPACE=1 timeout 45 kimi -p "hi"
# $H/logs/kimi-code.log:
#   ERROR mcp server unavailable  server=unreal-mcp transport=http status=failed reason="fetch failed"  [O]
```
The entry **parsed and registered** — transport inferred `http`, URL read correctly — and the
failure is the expected "nothing listening on :18000" (`fetch failed`), not a schema rejection.
Control: a genuinely invalid URL is rejected hard, so the schema *is* validating:
```bash
# url "not-a-url"  →
#   ERROR mcp config initial load failed
#   Error2: Invalid MCP server config in …/proj_bad/.mcp.json:
#     [ "code": "invalid_format", "message": "Invalid URL" ]                                          [O]
```
**Caveat (a) resolves in the row's favour**: `"type": "http"` is tolerated and ignored; `url` drives
transport inference (`if (typeof obj["url"] === "string") return {...obj, transport: "http"}`) **[O]**.

**Probe B — the condition the table omits.** With the workspace **untrusted** (the default), the
server is **skipped**, silently for practical purposes:
```bash
cd /var/tmp/r107-kimi-ver/proj_mcp && KIMI_CODE_HOME=$H timeout 25 kimi -p "hi"
# Warning: this folder is not trusted; skipped 1 project-level MCP server: unreal-mcp
#          (http: http://127.0.0.1:18000/mcp).
#   Run `kimi` here and choose "Trust this folder", or set KIMI_CODE_TRUST_WORKSPACE=1, to enable them.  [O]
```
Corroborated in the binary — the loader is gated on workspace trust:
`includeProject: this.trust.isTrusted()` **[O]**.

**Verdict: AGREE on the substance** (the editor-written `.mcp.json` is picked up as-is, filename and
location exactly right), **but the row's "Do nothing for MCP / no porting needed" recommendation is
incomplete.** In headless `kimi -p` — the mode this fleet itself runs in — an untrusted project
silently loses the server. §7 item 1 should read: *"Do nothing for MCP **and trust the workspace**
(`KIMI_CODE_TRUST_WORKSPACE=1`, or the interactive prompt); without it Kimi skips the
project-level server with only a warning."* This is a new, [O]-verified host fact, not a re-statement.

**Probe C — the anchor is the GIT ROOT, not the UE project root.** The upstream `setup.md:61-66`
gives the destination by *build kind*: a **source build** writes `.mcp.json` to the workspace root
*"alongside `Engine/`. Not next to the `.uproject`."* That is a **monorepo layout** — git root and
UE project root are different directories — which the table's row 11 does not cover. Measured
directly:

```bash
# layout: /var/tmp/r107-kimi-ver/mono_root is the git root
#         mono_root/MyGame/{MyGame.uproject, .mcp.json}   ← editor-written location for a source build
cd /var/tmp/r107-kimi-ver/mono_root/MyGame && KIMI_CODE_HOME=$H KIMI_CODE_TRUST_WORKSPACE=1 timeout 30 kimi -p "hi"
grep -i unreal $H/logs/kimi-code.log
#   (no line) — the server was NOT registered                                [O]

# CONTROL: same tree, cwd = git root, .mcp.json at the git root
cd /var/tmp/r107-kimi-ver/mono_root && KIMI_CODE_HOME=$H2 KIMI_CODE_TRUST_WORKSPACE=1 timeout 30 kimi -p "hi"
grep -i unreal $H2/logs/kimi-code.log
#   ERROR mcp server unavailable server=unreal-mcp transport=http status=failed reason="fetch failed"  [O]
#   (registered; fails only because nothing listens on :18000)

# DISCRIMINATOR: .mcp.json present at BOTH locations, cwd = the UE subdir
cd /var/tmp/r107-kimi-ver/mono_root/MyGame && KIMI_CODE_HOME=$H3 KIMI_CODE_TRUST_WORKSPACE=1 timeout 30 kimi -p "hi"
grep -i unreal $H3/logs/kimi-code.log
#   ERROR mcp server unavailable server=unreal-mcp … "fetch failed"          [O]
#   → the entry that registered is the GIT-ROOT one; the cwd copy was ignored
```
The last test isolates the variable: with a copy in *both* places, the cwd file alone is
insufficient and the git-root file alone is sufficient — so the read path is
`<git root>/.mcp.json`, exactly as `resolveMcpJsonPaths`' `projectRoot` key says. (Kimi also reads
`<cwd>/.kimi-code/mcp.json`, a *different* filename, which is why the cwd copy is not picked up.)

**Consequence for the recommendation.** In the default one-project-per-repo layout, git root and UE
project root coincide, so row 11 works as written. In a **source build / monorepo** — which
`setup.md` explicitly describes, and which the row's own hook logic anticipates by walking *upward*
from `$PWD` to find the `.uproject` — the editor writes `.mcp.json` where Kimi does not look, and
the integration silently yields no MCP server. §7 item 1 should read: *"Do nothing for MCP **and
trust the workspace, and make sure the `.mcp.json` sits at the git root** — for a source build
(multi-project repo) the editor's `GenerateClientConfig` writes it next to the `.uproject` in a
subdirectory, where Kimi will not find it; move or symlink it to the git root, or use
`<cwd>/.kimi-code/mcp.json` instead."*

**Cross-check against KIMI-ADAPT-LEAD's refreshed table (read only after my probes ran).** The
lead's r107 §6 register lists exactly one open item that a probe can settle: *"Editor's `.mcp.json`
write location == Kimi's `projectRoot` in a source build … equal in the common case, unverified
when they differ"*, with the settlement condition *"a source-build UE project whose git root ≠
workspace root, `.mcp.json` present, `/mcp` shows the server"*. **Probe C above is that experiment**
— the layout is exactly `git root` ≠ UE project root, `.mcp.json` present — and it **does not
settle in the equality direction: the file was NOT read** **[O]**. The register item should move
from `unverified` to **`falsified in the differ-case`**, with the residue narrowed to the live
`/mcp` display (still `unproven-runtime`, since no editor exists here). The lead's other additions
(row 11's trust gate, row 17, the `"type"` promotion) are independently **corroborated** by my
Probes A and B — reached separately, same results, different probe homes and ports.

### Row 12 — no Kimi target in `GenerateClientConfig`
```bash
grep -o "GenerateClientConfig [A-Za-z]*" upstream/skills/unreal-mcp/references/*.md | sort -u
# upstream/…/operations.md:GenerateClientConfig 
# upstream/…/operations.md:GenerateClientConfig ClaudeCode
# upstream/…/setup.md:GenerateClientConfig ClaudeCode                                              [O]
grep -rn "Kimi\|kimi" upstream/ --include=*.md --include=*.json ; echo $?   # exit=1, no matches  [O]
```
`operations.md:14` gives the fixed engine-side client list `ClaudeCode, Cursor, VSCode, Gemini,
Codex, All` **[O]**. **Verdict AGREE** — no Kimi target exists; extending it is an engine change.
See D4 for the reported-output discrepancy.

### Row 13 — permission modes `manual` / `yolo` / `auto`
```bash
kimi --help | grep -E 'yolo|--auto'
#   -y, --yolo   Start in Ask When Needed mode: …                       [O]
#   --auto       Start in Never Ask mode: …                             [O]
sed -n '1p' ~/.kimi-code/config.toml   # default_permission_mode = "auto"   [O]
```
Binary contains the mode literals `"manual"` / `"yolo"` / `"auto"` **[O]**. r103's C1 asserted
"Row 13's `config.toml:1` is **not** affected" — re-confirmed, still line 1 **[O]**. **AGREE.**

### Row 14 — no `CLAUDE_UE_HOOK_DEBUG` equivalent
```bash
grep -o 'CLAUDE_[A-Z_]*' $S | sort -u
# CLAUDE_FAMILY_WORD_RE / CLAUDE_THINKING_VISION_TOOL_PREFIXES / CLAUDE_VISION_TOOL_PREFIXES   [O]
```
Identical to the row's list — still exactly three, all model-vision heuristics. **AGREE.**

### Row 15 — Agent Skills directories
```bash
ls -d ~/.kimi-code/skills ~/.agents/skills ~/.claude/skills   # all three exist  [O]
grep -o '\.kimi-code/skills\|\.agents/skills\|\.claude/skills' $S | sort | uniq -c
#   7 .kimi-code/skills   /   3 .agents/skills   /   6 .claude/skills           [O]
```
The shipped `import-from-cc-codex` skill text names `$KIMI_CODE_HOME/skills/` and
`<project root>/.kimi-code/skills/` as the Kimi targets, and states `.agents` skills are already
supported natively **[O]** — independent corroboration that all three layers are real.
`upstream/skills/unreal-skill/SKILL.md:3` resolves and does scope itself away from harness skills **[O]**.
**AGREE.**

## 4. Defects found

Two classes: **citation defects** (D1, D2, D4 — no verdict changes) and **substantive defects**
(D3, D3b — both amend row 11 and the file's §7 recommendation).

- **D1 — row 2 pointer, stale a second time.** `:2932` (r101) → `:3290` (r103) → **`:3538`** (r107,
  file 3570 lines) **[O]**. §5's invalidation rule does not cover this class (it covers only
  "binary strings line N"), and r103's own warning "do not trust the number" was not applied to the
  number it published. Recommend: cite the block by `grep`, never by line.
- **D2 — row 5 pointer off by one.** Row cites `unreal-context.sh:47`; the `exit 0` is on **:46**
  **[O]**. Same 3-line block, no semantic impact.
- **D3 — row 11 omits the workspace-trust gate.** §3 above; one of two substantive findings this
  seat adds. A verified-here row (11) is *understated*, not overstated — the surface is real but
  conditional.
- **D3b — row 11 does not cover the monorepo/source-build case.** The loader reads
  `<git root>/.mcp.json`, while `setup.md:61-66` says a *source build* writes the file to the
  workspace root "not next to the `.uproject`". With git root ≠ UE project root and a cwd inside
  the UE subdir, the file is **not read at all** (Probe C, §3) **[O]**. Two further findings:
  (i) Kimi's project-local layer is the *differently named* `<cwd>/.kimi-code/mcp.json`, so a
  cwd copy named `.mcp.json` does nothing; (ii) Kimi's own shipped `import-from-cc-codex` skill
  text acknowledges the reverse asymmetry — *"Kimi reads the current working directory's
  Kimi-specific MCP file, not every project-root `.kimi-code/mcp.json` from subdirectories"* **[O]**.
  The row's "no porting needed" holds for one-project-per-repo and breaks for source builds.
- **D4 — row 12's reported output is narrower than the command returns.** §4.2 reports a single
  line (`GenerateClientConfig ClaudeCode`); re-running the same pattern here yields **three**
  lines, including a bare `GenerateClientConfig ` match on `operations.md` **[O]**. The
  `NONE-FOUND` verdict is unaffected (a bare token is not a client target), and r103's C3 re-run
  reported only two lines — so three separate runs reported three different line counts for the
  same command on the same bytes. Cause is `[?]` (likely `-o`/glob form differences between the
  runs); worth a one-line note so a future reader does not treat the reported output as exact.
- **Not a defect (resolved):** r103's "out of scope" item — the header's repo URL. Line 6 now reads
  `…-plugin` **[O]**, `curl -sIL` → `200`, and the no-plugin form → `404` **[O]**; `git log -S`
  shows r105 (commit `830095a`, "kimi-404 fold") landed the fix. Closed.
- **Docs prefix still holds:** all four root-relative docs paths → `404`, all four `/en/` → `200` **[O]**.

## 5. What is NOT claimed

- **No Unreal-side claim.** Every probe here exercised the *Kimi* loader with a synthetic project.
  Whether a real editor serves `unreal-mcp` on `:8000` remains `unproven-runtime`; `fetch failed`
  on a closed port is consistent with that and is *not* evidence about UE.
- **The row-11 probe used a URL with nothing listening**; it proves the entry *registers*, not that
  a live MCP session succeeds.
- **Binary-string pointers remain anchored to BuildID `5e67bdf9…` / sha256 `8ee7405d…`** — verified
  unchanged this round, so §5's invalidation rule stays untriggered. A CLI upgrade voids every
  line number in this shard.
- **Verdicts are per-row surface existence**, not endorsement of the row's recommendation; §7's
  ranked advice needs the D3 amendment.
