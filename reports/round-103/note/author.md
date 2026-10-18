# r103 SEAT-01 NOTE-AUTHOR — freshness note landed in `adaptation-kimi.md`

Lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin` · HEAD `c85a816` (r102 report-last; work
`c6f655d`) · probe date **2026-10-18**.

Scope: land the C1 freshness note for `corpus/knowledge/unreal-mcp/adaptation-kimi.md` (the file
this seat owns), fixing the three stale citation classes proposed in `reports/round-102/kimi-surfaces.md`
§4 (S1 config line, S2 doc URLs, S3 `/tmp` pointer). Every other row and line of the file is left
byte-stable. Read-only on every path outside the two files named in §0.

Label vocabulary: `verified-here` = reproduced by a command run on this host, output pasted verbatim
below. No Unreal runtime claim is made anywhere in this report: the editor is not installed, so
live-MCP behavior stays `unproven-runtime`.

---

## 0. Files written

| Path | What changed |
|---|---|
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | appended `## Correction note — 2026-10-18 (r103)` (363 → 506 lines); **lines 1-363 byte-identical** |
| `reports/round-103/note/author.md` | this evidence file |

Nothing else was written. `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`,
`corpus/fixtures/**`, `reports/round-101/**`, `reports/round-102/**`,
`corpus/knowledge/unreal-mcp/upstream/**` and `corpus/knowledge/unreal-mcp/.manifest.d/**` were
not touched.

---

## 1. Byte-stability of the r101 record (verified-here)

The note is **appended**, so the historical table cannot be damaged by it. Proof: the first 363
lines hash to the pre-edit whole-file digest, and the pre-edit copy is still on disk at
`/tmp/adapt-before.md`.

```bash
$ sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md   # BEFORE the edit
e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981  corpus/knowledge/unreal-mcp/adaptation-kimi.md
$ wc -l corpus/knowledge/unreal-mcp/adaptation-kimi.md      # BEFORE
363 corpus/knowledge/unreal-mcp/adaptation-kimi.md
```

```bash
$ head -363 corpus/knowledge/unreal-mcp/adaptation-kimi.md | sha256sum   # AFTER the edit
e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981  -
$ sha256sum /tmp/adapt-before.md
e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981  /tmp/adapt-before.md
$ diff <(head -363 corpus/knowledge/unreal-mcp/adaptation-kimi.md) /tmp/adapt-before.md && echo "IDENTICAL lines 1-363"
IDENTICAL lines 1-363
$ wc -l corpus/knowledge/unreal-mcp/adaptation-kimi.md      # AFTER
506 corpus/knowledge/unreal-mcp/adaptation-kimi.md
$ grep -c '^| [0-9]* |' corpus/knowledge/unreal-mcp/adaptation-kimi.md   # 15 rows intact
15
```

The pre-edit digest `e0f8ca9b…b4b981` is the same one recorded by `reports/round-101/r101-reviewer-c3.md`
and `reports/round-102/before/baseline-integrity.md:139`, so the r101 record is untouched relative to
the r102 baseline.

New section headings after the edit — the seven original sections plus the appended note:

```bash
$ grep -n '^## ' corpus/knowledge/unreal-mcp/adaptation-kimi.md
25:## 1. Adaptation table
52:## 2. Row notes
146:## 3. Live probes (reproduced on this host)
217:## 4. NONE-FOUND searches (exact commands and results)
270:## 5. Verification policy — proven vs unproven
306:## 6. Unproven-runtime register
320:## 7. Recommended adaptation, ranked by cost
337:## Provenance
367:## Correction note — 2026-10-18 (r103)
```

---

## 2. Binary anchor — §5's invalidation rule is NOT triggered (verified-here)

```bash
$ kimi --version
2.2.0
$ sha256sum /home/vgpnk/.kimi-code/bin/kimi
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  /home/vgpnk/.kimi-code/bin/kimi
$ readelf -n /home/vgpnk/.kimi-code/bin/kimi 2>/dev/null | grep -i 'Build ID'
    Build ID: 5e67bdf95c7646325b62decd0ca8d375d325ea19
```

Both cited identifiers (`2.2.0`, BuildID `5e67bdf9…`) and the sha256 r102 introduced
(`8ee7405d…`) reproduce exactly, so the invalidation rule scoped to "binary strings line N" is
**not** triggered. (`readelf` prints a batch of `Gap in build notes` warnings on this binary; they
are pre-existing noise, and the `NT_GNU_BUILD_ID` note resolves cleanly to the cited value.)

---

## 3. C1 — row 2's `config.toml:2932-2937` is void; the precedent is at **3290**, not 3219

This is the one place the seat's brief was **wrong** and I corrected it against measurement: the
brief said "~line 3219, VERIFY the exact line". 3219 is what r102 measured; the file has been
edited since, and the block moved again.

```bash
$ sed -n '2932,2937p' ~/.kimi-code/config.toml
reasoning_key = "reasoning_content"
support_efforts = [ "low", "medium", "high" ]

[models."opencode-go-7/longcat-2.0"]
provider = "opencode-go-7"
model = "longcat-2.0"
$ wc -l ~/.kimi-code/config.toml
3322 /home/vgpnk/.kimi-code/config.toml
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
3290:[[hooks]]
$ sed -n '3290,3294p' ~/.kimi-code/config.toml
[[hooks]]
event = "Notification"
matcher = "task\\.completed"
command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"
timeout = 5
$ stat -c '%s %y' ~/.kimi-code/config.toml
107496 2026-10-18 14:50:34.896343019 -0300
$ sed -n '1p' ~/.kimi-code/config.toml
default_permission_mode = "auto"
```

The cited range is a `[models.*]` table, exactly as r102 reported. The sole `[[hooks]]` table is at
**3290** with the same field vocabulary row 2 depends on (`event` / `matcher` / `command` /
`timeout`), event `Notification` (not `SessionStart`). Row 13's `config.toml:1` is unaffected.

**Drift table** — the line number is not a stable citation form:

| probe | file lines | `[[hooks]]` line |
|---|---|---|
| r101 (cited in the table) | — | 2932 |
| r102 (`kimi-surfaces.md` S1) | 3251 | 3219 |
| r103 (this seat) | **3322** | **3290** |

Independent corroboration, same numbers: `reports/round-103/note/configline.md` §0-§2 (SEAT-60
CONFIG-LINE-VERIFIER), which also records the block's `sha256sum` as `b1cfc756…2112f5` and confirms
exactly one `[[hooks]]` in the file. Because of this, the note deliberately **does not** present
3290 as the citation — it gives the drift-proof form ("the file's sole `[[hooks]]` block", located
by `grep -n`), with 3290 as a dated parenthetical. Citing 3290 as if stable would reproduce the very
defect being corrected.

---

## 4. C2 — the four doc URLs need an `/en/` prefix (verified-here)

```bash
$ for u in customization/plugins.html customization/hooks.html customization/mcp.html configuration/config-files.html; do
>   printf 'root %s -> ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' --max-time 15 "https://moonshotai.github.io/kimi-code/$u"
>   printf 'en   %s -> ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' --max-time 15 "https://moonshotai.github.io/kimi-code/en/$u"; done
root customization/plugins.html -> 404
en   customization/plugins.html -> 200
root customization/hooks.html -> 404
en   customization/hooks.html -> 200
root customization/mcp.html -> 404
en   customization/mcp.html -> 200
root configuration/config-files.html -> 404
en   configuration/config-files.html -> 200
```

All four root-relative paths 404; all four `/en/`-prefixed paths 200. **Content, not just status** —
the section anchors and facts the rows cite still render on the `/en/` pages:

```bash
$ curl -s --max-time 20 https://moonshotai.github.io/kimi-code/en/customization/plugins.html | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'Hooks in Plugins|Installation and Management|Plugin Manifest' | sort -u
Hooks in Plugins
Installation and Management
Plugin Manifest
$ curl -s --max-time 20 https://moonshotai.github.io/kimi-code/en/customization/plugins.html | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'per-user[^.]{0,120}'
per-user and apply to all projects; project-level installation scope is not yet supported
$ curl -s --max-time 20 https://moonshotai.github.io/kimi-code/en/customization/hooks.html | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'startup|resume|exit code 2|Return Values' | sort -u
exit code 2
resume
Return Values
startup
$ curl -s --max-time 20 https://moonshotai.github.io/kimi-code/en/configuration/config-files.html | sed -e 's/<[^>]*>/ /g' | tr -s ' ' | grep -oiE 'Top-level fields' | sort -u
Top-level fields
```

Row 9's verbatim quotation and rows 3/5's `startup` / `resume` / `exit code 2` facts both reproduce
on the prefixed page, so **no row's content changes — only the prefix**. Corroboration, including
that `/en/` and `/zh/` are hard path moves rather than redirects (`%{url_effective}` equals the
request): `reports/round-103/note/urls.md` §1-§3 (SEAT-07).

---

## 5. C3 — `/tmp/ue-skills-ref` → the vendored `upstream/` copy (verified-here)

```bash
$ ls -d /tmp/ue-skills-ref && git -C /tmp/ue-skills-ref rev-parse HEAD
/tmp/ue-skills-ref
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ ls -d /tmp/r101work
/tmp/r101work
```

Both `/tmp` trees are **currently live**, so §3.1-§3.3 and §4.2 re-run as written today — but `/tmp`
is not durable. Re-ran §4.2's search against the vendored copy instead:

```bash
$ cd corpus/knowledge/unreal-mcp
$ grep -o "GenerateClientConfig [A-Za-z]*" upstream/skills/unreal-mcp/references/*.md | sort -u
upstream/skills/unreal-mcp/references/operations.md:GenerateClientConfig ClaudeCode
upstream/skills/unreal-mcp/references/setup.md:GenerateClientConfig ClaudeCode
$ grep -rn "Kimi\|kimi" upstream/ --include=*.md --include=*.json ; echo "exit=$?"
exit=1
$ sha256sum upstream/hooks/hooks.json upstream/README.md
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  upstream/hooks/hooks.json
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  upstream/README.md
```

Same verdict as §4.2 (only `ClaudeCode`; zero Kimi awareness), and both digests match the subtree
manifest prefixes recorded in `corpus/knowledge/unreal-mcp/README.md:123,128`
(`259124f0…b5ebdc0c`, `483693ad…46b40e`), so the vendored copy is still the pinned content.

---

## 6. The 15 row pointers — all still resolve (verified-here)

The note claims "no row's verdict changes". Every `upstream/…:line` pointer in the file was
re-resolved against the vendored copy, and every one lands on the cited text:

```bash
$ cd corpus/knowledge/unreal-mcp
$ sed -n '4,6p' upstream/hooks/hooks.json      # row 2/3: SessionStart + matcher
    "SessionStart": [
      {
        "matcher": "startup|resume|clear",
$ sed -n '10p' upstream/hooks/hooks.json       # row 1: CLAUDE_PLUGIN_ROOT
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh",
$ sed -n '39p;45p' upstream/README.md          # row 6: /plugin install + marketplace
/plugin install unreal-engine-skills-for-claude-code@claude-plugins-official
/plugin marketplace add anthropics/claude-plugins-official
$ sed -n '50,57p' upstream/README.md           # row 9: enabledPlugins in .claude/settings.json
Commit this to `.claude/settings.json` in the project that should use the plugin. Anyone who trusts the project folder is prompted to install it automatically:

```json
{
  "enabledPlugins": {
    "unreal-engine-skills-for-claude-code@claude-plugins-official": true
  }
}
$ sed -n '64p;65p' upstream/README.md          # rows 7,10: /plugin Installed tab; /mcp
3. In Claude Code, run `/plugin`. The **Installed** tab should list `unreal-engine-skills-for-claude-code` as enabled. This confirms the plugin itself (skills, hooks) is loaded.
4. Run `/mcp`. Check for `unreal-mcp`, or `unreal-mcp-proxy` if you installed the proxy. A connected proxy does not prove that Unreal is reachable.
$ sed -n '72p;92p' upstream/README.md          # rows 11,13
> **Note:** This plugin does not ship a static `.mcp.json` file. Run `ModelContextProtocol.GenerateClientConfig ClaudeCode` in the editor console to generate it from the current server port and URL; re-run after changing either.
**`--dangerously-skip-permissions` removes the per-tool approval gate.** In that mode Claude can drive the editor and run Python through `execute_tool_script` with no further consent. A bad prompt in that mode can reach into the project and modify a large amount of state before you notice. Prefer not to run Claude Code with `--dangerously-skip-permissions` while this plugin is loaded; if you do, keep the blast radius small (narrow prompts, read-heavy tasks, a throwaway sandbox project).
$ sed -n '61p;70,79p;129p' upstream/skills/unreal-mcp/references/setup.md   # rows 10,11
**From a running editor (preferred):** run `ModelContextProtocol.GenerateClientConfig ClaudeCode` in the console (or `All` to write configs for every supported client: `ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`). Re-running merges into the existing JSON, so it is safe after changing the port or URL. Codex is the exception: it uses TOML and the writer refuses to overwrite an existing `.codex/config.toml`. Edit that one by hand if it already exists.
```json
{
  "mcpServers": {
    "unreal-mcp": {
      "type": "http",
      "url": "http://127.0.0.1:8000/mcp"
    }
  }
}
```
- `/mcp` in Claude Code lists `unreal-mcp`, or `unreal-mcp-proxy` when installed, as connected.
$ sed -n '14p' upstream/skills/unreal-mcp/references/operations.md   # row 12
| `ModelContextProtocol.GenerateClientConfig <client>` | Regenerate the per-client config file. Args: `ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, `All`. |
$ sed -n '5p;8p;47p;61p;84p' upstream/hooks/unreal-context.sh   # rows 1,4,5,11
# Opt-in debug logging: set CLAUDE_UE_HOOK_DEBUG to any non-empty value.
  if [ -n "$CLAUDE_UE_HOOK_DEBUG" ]; then
fi
[ -f "$project_root/.mcp.json" ] && mcp_config_present="true"
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$escaped_context"
$ sed -n '1p' upstream/.claude-plugin/plugin.json
{
```

Row 14's `unreal-context.sh:5,8` and row 4's `:84` resolve as cited; row 5's `:47` resolves to a
`fi` (the exit-code semantics live in the block ending there). All 17 distinct `upstream/…:line`
pointers in the file still resolve, which is what the gate's pointer sweep checks mechanically (§7).

---

## 7. Gate — the delivered file passes (verified-here)

The gate's check 4 sweeps every `*.md` under the subtree, **including `adaptation-kimi.md` itself**,
so the appended note had to be written so as not to introduce a dangling pointer. Measured on the
delivered file (final state, both files on disk), twice in a row:

```bash
$ for i in 1 2; do bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E 'POINTERS|UNRESOLVED|CLONE_HEAD|GATE RESULT'; done
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

Full transcript tail:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | tail -30
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS

CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
...
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
```

`UNRESOLVED=0` is the binding invariant (`gate/README.md:118`: "the binding invariant is
`UNRESOLVED=0`"; the count is scanner-relative and de-duplicates by path).

**A transient CHECK 2 failure is worth recording for the round.** One intermediate run reported
`GATE RESULT: FAIL (checks failed: 1)` with check 4 still clean:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -vE '^OK ' | head -40
CHECK 2 clone-equivalence
FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS
STEP=FAIL
CHECK 4 pointer-sweep
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS
```

The network was in fact up at that moment — `curl` returned 200 and `git ls-remote` returned the pin
on the very next command:

```bash
$ curl -sI --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
200
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh >/tmp/g.out 2>&1; echo "exit=$?"
exit=0
```

So CHECK 2 is **flaky under concurrent load** (the gate is network-dependent, and several seats were
running it simultaneously this round) and its failure mode is indistinguishable from a genuine
upstream-unreachable condition — the `BLOCKED, not PASS` wording is honest, but a reader of a bare
`GATE RESULT: FAIL` cannot tell a flake from a real break. That is a concrete case for the r103 gate
hardening brief (A4: a distinct `BLOCKED` signal with a declared exit code). It is **not** a defect
in this seat's file: check 4 passes in every run, including the flaky one.

**One correction to the seat brief.** The brief said "the gate currently prints POINTERS=87". It
printed **88** on the untouched baseline I ran *before* editing — verified separately by extracting
the pointer set from the pre-edit copy of the file. The delta is not mine:

```bash
$ # pointer extraction (gate check 4's union), pre-edit copy vs post-edit file
$ comm -13 /tmp/ptrs-before.txt /tmp/ptrs-after.txt    # NEW pointers introduced by the note
reports/round-103/note/author.md
/tmp/kimi_strings.txt
$ comm -23 /tmp/ptrs-before.txt /tmp/ptrs-after.txt    # REMOVED pointers
(none)
```

Only one new path is real (`reports/round-103/note/author.md`, this file — and it is now on disk,
which is why the sweep resolves it). `/tmp/kimi_strings.txt` is excluded by the gate's `case`
filter (not a `corpus/*`/`reports/*` prefix), so it does not enter the sweep. The remaining +1 over
87 is therefore **peer churn, not this seat**: `reports/round-103/` was created by other seats
during my run (`ledger-check.md`, `gate/clean.raw.txt`, `note/configline.md`, `note/urls.md`) and
those files add pointers of their own. That is also why the count moved between my own runs
(88 → 89 → 90), the single unresolved path in the 89-run being `reports/round-103/note/author.md`
*before this file existed*:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh 2>&1 | grep -E 'POINTERS|UNRESOLVED|GATE RESULT'
POINTERS=89 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
GATE RESULT: FAIL (checks failed: 1)      # ← the dangling path was this evidence file, mid-write
```

I fixed that by creating this file, and the delivered state is `POINTERS=90 … UNRESOLVED=0 PASS`
above. **Lesson for the round:** an evidence file cited *inside* the corpus cannot be cited before
it exists — the gate resolves the pointer on disk, so the citation and the file must land together.

---

## 8. Independent corroboration from sibling seats (same round)

| Citation class | This seat's measurement | Peer verification | Agrees? |
|---|---|---|---|
| S1 config line | `[[hooks]]` at **3290**, file 3322 lines, event `Notification` | `reports/round-103/note/configline.md` (SEAT-60) — same numbers, block sha256 `b1cfc756…2112f5`, exactly one `[[hooks]]` | yes |
| S2 doc URLs | 4/4 root 404, 4/4 `/en/` 200, content intact | `reports/round-103/note/urls.md` (SEAT-07) — same matrix, plus `/zh/` 200 and no-redirect evidence | yes |
| S3 `/tmp` pointer | `/tmp/ue-skills-ref` live at pin; vendored digests match manifest | — | n/a |

Both peer notes are read-only reports; neither wrote `adaptation-kimi.md`, so there is no
write-write conflict on this seat's file.

---

## 9. Fourth defect — reported, deliberately NOT repaired

`adaptation-kimi.md:6` cites the upstream repository without the `-plugin` suffix, and that URL is
404:

```bash
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code
404
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
200
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code main
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine-skills-for-claude-code/' not found
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main
$ sed -n '19p' corpus/knowledge/unreal-mcp/PROVENANCE.md
| repository | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | `git -C /tmp/ue-skills-ref remote -v` **[O]** |
```

`PROVENANCE.md:19` already carries the correct URL and the clone's `origin` is the `-plugin` form, so
the pin, the SHA and the provenance chain are unaffected — it is a one-token display defect in the
header. The seat's mandate named **three** citation classes (S1/S2/S3), so this fourth one is
recorded as an explicit out-of-scope section **inside** the landed note and left uncorrected: line 6
is part of the r101 record above the heading, and repairing it is either a further dated note or a
separate declared repair. Surfaced independently by `reports/round-103/note/urls.md` §4 (SEAT-07),
which reaches the same "one token, not applied here" conclusion.

---

## 10. Boundaries

- Wrote only `corpus/knowledge/unreal-mcp/adaptation-kimi.md` (append) and this file. No git
  commit/push/checkout/reset was run; the tree is left dirty for the round's integrator.
- `adaptation-kimi.md` lines 1-363 are byte-identical to the r102 baseline digest
  (`e0f8ca9b…b4b981`) — verified in §1. No historical claim was rewritten; the note is dated and
  names exactly which citation is void and what replaced it.
- No Unreal runtime claim is made anywhere: the editor is not installed on this host, so every §6
  item remains `unproven-runtime`. The loopback MCP endpoint `http://127.0.0.1:8000/mcp` is unbound
  here and was not contacted.
- Upstream pin untouched: `a6aa73ada02a9fb1f5415bec491f9942c519b297`.
