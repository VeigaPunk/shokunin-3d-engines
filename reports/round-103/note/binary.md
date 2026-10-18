# r103 · SEAT-06 BINARY-REPROBE — `kimi` binary identity vs the §5 invalidation pin

Round r103 · lane game-dev-3d-shokunin · written 2026-10-18.
Seat scope: re-probe the installed `kimi` CLI — `kimi --version`, BuildID, `sha256sum` — and decide
whether `corpus/knowledge/unreal-mcp/adaptation-kimi.md` §5's invalidation pin
(BuildID `5e67bdf9…`) needs a bump, or whether a freshness note is owed.
Every claim carries the command that produced it and the verbatim output observed on this host.
Labels: **[O]** observed here, **[I]** inference. No Unreal runtime claim is made anywhere in this
file (editor not installed; live-MCP unproven by construction).

---

## 0. Verdict

**The pin HOLDS. No bump to the §5 invalidation table, and no freshness note is owed on
binary-identity grounds.** The installed binary is the same build the pin names: version `2.2.0`,
BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19` — a byte-for-byte match, corroborated by a
sha256 that is itself unchanged since r101.

**One defect found, and it is not a staleness defect.** §3.4's code block prints
`strings -n 6 … | grep -n …` but quotes line numbers (`1832505`/`1832506`) that only that
extraction's sibling convention — `strings -n 3`, the convention §4's own preamble declares —
produces. Run verbatim, §3.4's command returns `749729`/`749730`, not the numbers it prints. The
cited text is correct and every pointer re-derives; only the printed command does not reproduce its
own quoted numbering. This is a **citation-hygiene** defect in a `static-only` row, not a moved pin.
Details in §3; it needs the owning seat's decision, and it is not mine to edit.

**A second, out-of-seat drift was noticed while cross-checking** (§5): r102's proposed C1 text cites
`~/.kimi-code/config.toml:3219` for the sole `[[hooks]]` table, but on this host that block is now
at line **3290**. That belongs to the C1 coverage claim's owning seat, not this one; recorded here
only because this seat ran the receipt.

---

## 1. Binary identity — the anchor (verified-here)

```bash
$ kimi --version
2.2.0
$ sha256sum /home/vgpnk/.kimi-code/bin/kimi
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  /home/vgpnk/.kimi-code/bin/kimi
$ md5sum /home/vgpnk/.kimi-code/bin/kimi
40870be23c0d8e76dcae783eb0502347  /home/vgpnk/.kimi-code/bin/kimi
$ readelf -n /home/vgpnk/.kimi-code/bin/kimi | grep -i -A2 'build id'
  GNU                  0x00000014	NT_GNU_BUILD_ID (unique build ID bitstring)
    Build ID: 5e67bdf95c7646325b62decd0ca8d375d325ea19
$ file /home/vgpnk/.kimi-code/bin/kimi
… ELF 64-bit LSB executable, x86-64 … BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19,
for GNU/Linux 3.2.0, with debug_info, not stripped, too many notes (256)
$ stat -c 'mtime=%y size=%s' /home/vgpnk/.kimi-code/bin/kimi
mtime=2026-10-14 19:58:50.344019494 -0300 size=191892672
$ kimi --version | xxd
00000000: 322e 322e 300a                            2.2.0.
```

**[O]** Both identifiers the doc cites at `adaptation-kimi.md:9-10` reproduce exactly: version
`2.2.0` and BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`. `file` and `readelf -n` agree on the
BuildID, and `kimi --version` emits the bare string `2.2.0\n` (7 bytes, no build suffix), so there is
no second version channel to disagree with.

| channel | observed | vs pin |
|---|---|---|
| `kimi --version` | `2.2.0` | match (`adaptation-kimi.md:9`, §5) |
| `readelf -n` BuildID | `5e67bdf95c7646325b62decd0ca8d375d325ea19` | **exact match** to §5 pin |
| `file` BuildID[sha1] | `5e67bdf95c7646325b62decd0ca8d375d325ea19` | match (independent reader) |
| `sha256sum` | `8ee7405d…e5b6111af` | unchanged since r101/r102 |
| `md5sum` | `40870be23c0d8e76dcae783eb0502347` | new datum, not previously recorded |
| size / mtime | `191892672` / `2026-10-14 19:58:50 -0300` | same binary, no rebuild |

The sha256 is the strongest single channel: `8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af`
is the value r101 first recorded (`reports/round-101/probes/kimi-surfaces.md:28`) and r102 repeated
(`reports/round-102/kimi-surfaces.md:43,309-310`). It is byte-identical today, so the binary has
neither been upgraded nor silently rebuilt. BuildID is the anchor the doc documents; sha256 is the
one that would catch a same-BuildID rebuild **[I]** — both hold.

---

## 2. §5's pin needs no bump — and the invalidation rule was actually exercised

§5 (`adaptation-kimi.md:290-293`) reads: any pointer of the form "`kimi` binary strings line N" is
valid **only** for BuildID `5e67bdf9…`; a CLI upgrade invalidates every such pointer, and the remedy
is to re-run §4's greps rather than trust the line numbers.

The antecedent has not fired — the BuildID is identical, so by the rule's own terms nothing is
invalidated. But "the pin matches" is a weak test on its own, so the rule's prescribed remedy was
executed: §4's greps were re-run from scratch, and the line-numbered §3.4/§3.5 pointers were
re-derived.

### 2.1 Strings re-extracted fresh (not reused from r101)

```bash
$ strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /tmp/kimi_strings_r103b.txt
$ wc -l /tmp/kimi_strings_r103b.txt
2644877 /tmp/kimi_strings_r103b.txt
```

**[O]** 2,644,877 lines. The r101 extraction `/tmp/kimi_strings.txt` still exists on this host, and
the two files are **byte-identical**:

```bash
$ sha256sum /tmp/kimi_strings.txt /tmp/kimi_strings_r103b.txt
380092949dc22e60778bd5dce77b5cbb9912ff87d662db3cace59e0e115e225d  /tmp/kimi_strings.txt
380092949dc22e60778bd5dce77b5cbb9912ff87d662db3cace59e0e115e225d  /tmp/kimi_strings_r103b.txt
```

**[O]** Same hash. This is the strongest available evidence that the extraction is deterministic and
that the r101 pointers were derived from exactly these bytes — the r101 intermediate artifact
survived and still reproduces, so no r101 pointer is at the mercy of a lost `/tmp` file.

### 2.2 §4's greps, re-run

```bash
$ grep -c enabledPlugins ~/.kimi-code/config.toml     # 0
$ grep -c enabledPlugins /tmp/kimi_strings_r103b.txt  # 0
$ grep -c "settings.json" /tmp/kimi_strings_r103b.txt # 0
$ grep -o "\.claude/settings[a-z.]*" /tmp/kimi_strings_r103b.txt | sort -u   # (empty)
$ grep -c "CLAUDE_PLUGIN_ROOT" /tmp/kimi_strings_r103b.txt  # 0
$ grep -c "additionalContext" /tmp/kimi_strings_r103b.txt   # 0
$ grep -o "CLAUDE_[A-Z_]*" /tmp/kimi_strings_r103b.txt | sort -u
CLAUDE_FAMILY_WORD_RE
CLAUDE_THINKING_VISION_TOOL_PREFIXES
CLAUDE_VISION_TOOL_PREFIXES
```

**[O]** Every §4.1/§4.3/§4.4/§4.5 result reproduces: four zeros, one empty set, and the same three
`CLAUDE_*` names. §4.2's upstream greps also reproduce against `/tmp/ue-skills-ref`:

```bash
$ grep -o "GenerateClientConfig [A-Za-z]*" /tmp/ue-skills-ref/skills/unreal-mcp/references/*.md | sort -u
…/operations.md:GenerateClientConfig ClaudeCode
…/setup.md:GenerateClientConfig ClaudeCode
$ grep -rn "Kimi\|kimi" /tmp/ue-skills-ref --include=*.md --include=*.json   # (no matches)
```

**[O]** The client target list still resolves to `ClaudeCode` only, and the upstream plugin still has
no Kimi awareness. The pinned clone is intact: `git -C /tmp/ue-skills-ref rev-parse HEAD` →
`a6aa73ada02a9fb1f5415bec491f9942c519b297`, exactly the upstream pin.

### 2.3 The vendored copy backs the §4.2 substitution

S3 in r102's note proposed the vendored copy as the durable substitute for `/tmp/ue-skills-ref`. That
substitution is sound — the vendored tree verifies clean:

```bash
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
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
   exit=0
```

**[O]** 12/12 `OK`, `exit=0`. So the §4.2 greps can be re-run from `upstream/` with no `/tmp`
dependency, and the answer will be the same bytes.

---

## 3. The §3.4 defect: printed command ≠ printed line numbers

This is the only finding of substance, and it is a citation-hygiene defect, not a staleness one.

§3.4 (`adaptation-kimi.md:200-207`) prints a command and then quotes its output:

```bash
strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -n 'KIMI_PLUGIN_ROOT_PATH\|KIMI_PLUGIN_DIR_PATH'
# 1832505: KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
# 1832506: KIMI_PLUGIN_DIR_PATH  = ".kimi-plugin/plugin.json";
```

Run verbatim on this host, that command does **not** produce those line numbers:

```bash
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -n 'KIMI_PLUGIN_ROOT_PATH\|KIMI_PLUGIN_DIR_PATH'
749357:	const rootJsonPath = node_path.default.join(pluginRoot, KIMI_PLUGIN_ROOT_PATH);
749358:	const dirJsonPath = node_path.default.join(pluginRoot, KIMI_PLUGIN_DIR_PATH);
749363:		message: `No manifest at ${KIMI_PLUGIN_ROOT_PATH} or ${KIMI_PLUGIN_DIR_PATH}`
749724:var KIMI_PLUGIN_ROOT_PATH, KIMI_PLUGIN_DIR_PATH, PLUGIN_SYSTEM_PROMPT_MAX_BYTES, UNSUPPORTED_RUNTIME_FIELDS;
749729:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
749730:	KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json";
```

**[O]** Under `-n 6` the assignment pair sits at **749729/749730**. The quoted `1832505/1832506`
belong to a different extraction. The doc's own §4 preamble (`adaptation-kimi.md:219`) declares that
convention: "Binary strings were extracted once with `strings -n 3 …`". Under `-n 3` the quoted
numbers reproduce **exactly**:

```bash
$ strings -n 3 /home/vgpnk/.kimi-code/bin/kimi > /tmp/kimi_strings_r103b.txt
$ grep -n 'KIMI_PLUGIN_ROOT_PATH = \|KIMI_PLUGIN_DIR_PATH ' /tmp/kimi_strings_r103b.txt
1832505:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
1832506:	KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json";
$ sed -n '1832505,1832506p' /tmp/kimi_strings_r103b.txt
	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
	KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json";
```

**[O]** Line 1832505 of the `-n 3` extraction *is* `KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";`.

The same split applies to §3.5's pointer. It cites "strings line 1743845" for `resolveMcpJsonPaths`:

```bash
$ sed -n '1743845p' /tmp/kimi_strings_r103b.txt          # -n 3  → reproduces
async function resolveMcpJsonPaths(input) {
$ strings -n 6 … | grep -n 'resolveMcpJsonPaths'          # -n 6  → 671899, not 1743845
671899:async function resolveMcpJsonPaths(input) {
```

**[O]** `1743845` is correct under `-n 3`; the `-n 6` extraction puts the same line at `671899`.

### 3.1 Why the numbers shift — arithmetic check

```bash
$ strings -n 3 /home/vgpnk/.kimi-code/bin/kimi | wc -l
2644877
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | wc -l
1113663
```

**[O]** Raising the minimum length from 3 to 6 drops 1,531,214 lines, so every downstream line
number moves. Both extractions are deterministic and both reproduce; they simply number differently.
The doc is internally consistent under one convention (`-n 3`, the §4 preamble's) and inconsistent
with the command it prints in §3.4 (`-n 6`). The binary is not stripped and carries `debug_info`
(`file` above), so long source-embedded strings appear under both settings — the `KIMI_PLUGIN_*`
assignment pair is found either way, just at two different numbers.

### 3.2 Severity, and what is *not* wrong

- The **text** cited at §3.4/§3.5 is correct, and both pointers are **resolvable** — §5's
  "resolvable" standard is met under `-n 3`.
- The `-n 6` variant also still *finds* the strings (at 749729/749730); nothing dangles and no
  `NONE-FOUND` row is affected. Only the quoted line numbers fail to match the quoted command.
- **[I]** The likely cause is that the line numbers were taken from the §4-preamble `-n 3`
  extraction while the §3.4 code block was written with `-n 6`. A reader who follows §3.4's command
  verbatim will see 749729 and conclude the doc is stale — a false alarm the fix removes.
- Suggested minimal fix (for the owning seat; **not applied here** — this seat owns only this file):
  change §3.4's command to `strings -n 3 …` to match §4's declared convention, or annotate the block
  with the extraction it was numbered against. A one-line dated correction note satisfies the
  discipline; no silent rewrite of §3.4's numbers is warranted.

---

## 4. Verdict on the §5 table

| question | answer | receipt |
|---|---|---|
| `kimi --version` today | `2.2.0` | §1 |
| BuildID today | `5e67bdf95c7646325b62decd0ca8d375d325ea19` | §1 |
| Equals the §5 invalidation pin? | **Yes — exact** | §1 |
| sha256 changed since r101? | **No** (`8ee7405d…`) | §1 |
| §4 NONE-FOUND greps still 0? | **Yes**, all of them | §2.2 |
| §3.4/§3.5 pointers resolvable? | **Yes**, under `-n 3` | §3 |
| §3.4's printed command reproduces its own line numbers? | **No** (`-n 6` → 749729, not 1832505) | §3 |
| Does the §5 table need a bump? | **No bump.** §5's pin is correct as written. | — |
| Is a freshness note owed on binary grounds? | **No.** Nothing has moved. | — |
| Is a citation-hygiene correction owed? | **Yes** — §3.4's `-n 6`/`-n 3` mismatch | §3 |

**[O]** The §5 invalidation rule is correctly scoped and correctly pinned. It did not fire. The one
thing this seat would put in front of the owning seat is §3's command/numbering mismatch, which is a
one-line fix and does not touch the pin.

---

## 5. Out-of-seat drift noticed while cross-checking (routed, not repaired)

Cross-referencing r102's C1 proposal surfaced a second, unrelated drift. r102's note
(`reports/round-102/kimi-surfaces.md:28,206,318,334`) states the file's only `[[hooks]]` table is at
`~/.kimi-code/config.toml:3219` and proposes citing that line. On this host it is at **3290**:

```bash
$ grep -n '^\[\[hooks\]\]' ~/.kimi-code/config.toml
3290:[[hooks]]
$ sed -n '3290,3295p' ~/.kimi-code/config.toml
[[hooks]]
event = "Notification"
matcher = "task\\.completed"
command = "notify-send -a 'Kimi Code' 'Background task completed' 'A Kimi Code background task finished'"
timeout = 5
$ sed -n '3219p' ~/.kimi-code/config.toml
(blank line)
$ grep -n 'event = ' ~/.kimi-code/config.toml
3291:event = "Notification"
$ stat -c '%s bytes mtime=%y' ~/.kimi-code/config.toml
107496 bytes mtime=2026-10-18 14:50:34.896343019 -0300
```

**[O]** One `[[hooks]]` table, now at line 3290, `event = "Notification"`; line 3219 is blank; the
config was last modified `2026-10-18 14:50:34 -0300` (after r102 ran). The r102 observation was
accurate when made — this is ordinary config drift, not an r102 error. **The practical consequence
for C1: a proposed note that hard-codes `config.toml:3219` would land already stale.** The
file-relative phrasing r102 itself suggests ("`[[hooks]]` at the file's sole such block") is the
robust form. This is C1's owning seat's call, not this one's; recorded here because this seat holds
the receipt.

**Addendum (dated, appended after this section was written).** While this note was being finalized
the C1 seat landed its freshness note in `adaptation-kimi.md` (`mtime=2026-10-18 15:32:15 -0300`,
`git diff --stat` → `117 insertions(+)`). That landed note measures the `[[hooks]]` line at **3290**
and cites it as "the file's sole `[[hooks]]` block (line 3290 as measured r103)" — the same value
this seat observed independently, and the robust file-relative phrasing. So §5's concern is already
resolved in the landed text, not left open. No further action is owed from this seat.

**[O]** `stat -c '%y' corpus/knowledge/unreal-mcp/adaptation-kimi.md` →
`2026-10-18 15:32:15.370123701 -0300`; `git diff … | grep '^+.*3290'` → `+3290:[[hooks]]`.
Note the earlier r102 figures (2932 → 3219 → 3290) are three measurements of a file the operator
edits continuously, each accurate when taken.

---

## 6. What this file does not claim

- No Unreal Editor, MCP endpoint, engine binary, or live tool call was involved. This seat ran only
  `kimi --version`, `file`, `readelf`, `strings`, `grep`, `sha256sum`/`md5sum`, `stat`, and `git
  rev-parse`. No runtime claim is made anywhere.
- "Pin holds" means *the installed BuildID equals §5's documented BuildID* and the sha256 is
  unchanged. It is not a claim that §4's `NONE-FOUND` rows are true of the product — only that they
  still reproduce against these bytes.
- The §3 finding is about the doc's command/numbering consistency, not about whether the cited text
  exists; the text exists under both extractions.
- This seat owns `reports/round-103/note/binary.md` only. `adaptation-kimi.md` was read, never
  written; §3.2's suggested fix and §5's drift are routed to their owning seats.
