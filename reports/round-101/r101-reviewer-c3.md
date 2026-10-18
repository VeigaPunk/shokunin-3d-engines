# SEAT-48 REVIEW — C3 calibration, non-author verification

Round: r101 · Lane: game-dev-3d-shokunin · Seat: **SEAT-48 (review)**
Target claim: **C3 (calibration)** — Claude→Kimi adaptation table + proven/unproven
verification policy, **every row carrying a resolvable source pointer**.
Reviewed artifact: `corpus/knowledge/unreal-mcp/adaptation-kimi.md`
(sha256 `e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981`, 363 lines,
21744 bytes).

Review mode: **non-author, independent.** I did not write `adaptation-kimi.md`, any
`executability/` card, `README.md`, `PROVENANCE.md`, or any `.manifest.d/` manifest.
The only new repo file is this report; scratch is `/tmp/s48/`.

**Byte custody.** The artifact was still being edited when I started (I first read it at
330 lines, `wc -c` 20524; by seat close it was 363 lines, 21744 bytes). Every number below
was re-derived on the **final** bytes, sha `e0f8ca9b…`, and the hash was re-checked after
the last measurement and had not moved. `git status --porcelain` shows the whole
`corpus/knowledge/unreal-mcp/` subtree untracked (this round's landing is uncommitted by
instruction); nothing was committed by this seat.

Host receipts used (cited from the round brief, not re-derived): Arch Linux, 32 cores, 30G
RAM; Unreal Editor NOT installed. Versions actually observed here: `git 2.55.0`,
`Python 3.14.7`, `kimi` CLI `2.2.0` (BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19`).

---

## Verdict

**C3 CONFIRMED — every row carries a resolvable source pointer.** Five findings, all low or
informational (F1 LOW actionable, F2 LOW, F3–F5 INFO); none leaves a row pointerless.

- **15/15 table rows carry at least one `upstream/…` pointer.** 18 `upstream/` pointers
  total; all 18 resolve against the corpus root and are in range.
- **15/15 rows carry exactly one status token** from `verified-here` | `static-only` |
  `unproven-runtime`: **6 `verified-here`, 9 `static-only`, 0 `unproven-runtime`** in the
  table (the `unproven-runtime` items live in the separate §6 register, which is the correct
  place for them — see F3).
- The three other pointer classes the table uses also resolve: 4 host-config pointers
  (`~/.kimi-code/…`) in range with matching content; the binary-strings line refs resolve
  against the declared BuildID; the docs-page pointers resolve to live pages whose text
  confirms the rows (fetched, see §3).
- **Gates (the round's own close-out protocol):** G5 links `broken=0` PASS; G6 pointers on
  the C3 file alone `POINTERS=57 UNRESOLVED=0` PASS; G7 all three declared artifacts
  PRESENT; G4 `UNLABELED=0` PASS. Both negative controls (G5, G6) correctly flip to FAIL.
- **One genuine content mismatch:** row 5's primary pointer lands one line off the line it
  means (F1).

---

## 1. Method — resolve every pointer form, not just the one the checker knows

The round's close-out protocol ships a `pointer-check.sh` that recognises **only** the
`upstream/<path>:<line>` form, resolved against `corpus/knowledge/unreal-mcp/`. I
materialised that script verbatim from `r101-verification-protocol.md` §0 and confirmed it
reproduces the protocol's own published output before extending it:

```
$ bash /tmp/s48/pointer-check.sh reports/round-101 corpus/knowledge/unreal-mcp
POINTERS=78 UNRESOLVED=0
STEP=PASS
```

`POINTERS` is a moving denominator: sibling seats keep adding reports to
`reports/round-101/`, so the total grows between runs (I observed 61 → 78 → 82 → 84 across
this seat). The stable property, and the one the gate asserts, is `UNRESOLVED=0`. The C3
artifact's own count is fixed at `POINTERS=57` for the pinned sha.

Then I wrote an independent resolver covering **all five** pointer classes the C3 table
actually uses, because a checker that only knows one form would silently pass the others:

| class | example | how resolved | count |
|---|---|---|---|
| `upstream/<path>:<line>` | `upstream/hooks/hooks.json:6` | file exists under corpus root; line in `[1, wc -l]` | 18 |
| host config | `~/.kimi-code/config.toml:2932-2937` | file exists; range in bounds | 4 |
| binary strings line | `strings` line 1743845 | re-extracted strings; BuildID match; content compare | 3 |
| docs page | `customization/plugins.html` | fetched over the network; text compare | 8 |
| internal `§` ref | `§3.1`, `§4.1`, `§6` | section heading present in the same file | 10 |

Resolution is not the same as correctness, so every class was also **content-checked**, and
the seat's required 5-pointer hand spot-check was run on the strongest rows (§3).

---

## 2. Claim checks, with the command and its observed output

### 2.1 Every row carries a pointer — 15/15

```
$ python3 …  # rows = lines matching '^| <N> |', cells split on unescaped '|'
ROWS=15
  row  1 L34 status=static-only      upstream-ptrs=1
  row  2 L35 status=verified-here    upstream-ptrs=1
  row  3 L36 status=verified-here    upstream-ptrs=1
  row  4 L37 status=verified-here    upstream-ptrs=1
  row  5 L38 status=static-only      upstream-ptrs=1
  row  6 L39 status=static-only      upstream-ptrs=1
  row  7 L40 status=static-only      upstream-ptrs=1
  row  8 L41 status=verified-here    upstream-ptrs=1
  row  9 L42 status=verified-here    upstream-ptrs=1
  row 10 L43 status=static-only      upstream-ptrs=2
  row 11 L44 status=verified-here    upstream-ptrs=2
  row 12 L45 status=static-only      upstream-ptrs=2
  row 13 L46 status=static-only      upstream-ptrs=1
  row 14 L47 status=static-only      upstream-ptrs=1
  row 15 L48 status=static-only      upstream-ptrs=1
STATUS VIOLATIONS=0
```

Note the three rows whose *mechanism* cells contain escaped pipes (`startup\|resume\|clear`
in rows 3, 7, 12). A naive `split('|')` mis-parses those rows and reports garbage statuses
(my first pass did exactly that: it read row 3's status as `` clear` ``). Splitting on
unescaped `|` only is what makes the count meaningful. The token counts come out
`{'static-only': 9, 'verified-here': 6}` — 15 rows, no row without a token, no row with two.

### 2.2 Every pointer resolves — 18/18 upstream, 4/4 host, in range

```
$ python3 …  # upstream/ tokens across the 15 row-pointer cells
TOTAL backtick tokens across 15 row-pointer cells: 40
TOKEN KINDS: {'upstream-path': 18, 'binary-region': 3, 'other': 6, 'docs-page': 8, 'host-config': 5}
  upstream-form: OK=18 BAD=0

=== host-config tokens (~/...) ===
  row 2: OK ~/.kimi-code/config.toml:2932-2937 -> 2964 lines
  row 7: OK ~/.kimi-code/plugins/installed.json:1-13 -> 14 lines
  row 11: OK ~/.kimi-code/mcp.json:1-11 -> 11 lines
  row 13: OK ~/.kimi-code/config.toml:1 -> 2964 lines
  row 15: ~/.kimi-code/skills/  [no line]
```

The one host pointer without a line number is row 15's `~/.kimi-code/skills/`, a directory
reference; the directory exists and is a valid pointer of its kind.

### 2.3 The gates, run on the C3 artifact

```
$ bash /tmp/s48/linkcheck.sh corpus/knowledge/unreal-mcp/upstream        # G5
md_files=6 links_total=3 relative=2 absolute=1 fragment_only=0 broken=0
STEP=PASS                                          exit=0

$ bash /tmp/s48/pointer-check.sh corpus/knowledge/unreal-mcp/adaptation-kimi.md corpus/knowledge/unreal-mcp   # G6, C3 file alone
POINTERS=57 UNRESOLVED=0
STEP=PASS                                          exit=0

$ for p in …/README.md …/PROVENANCE.md …/adaptation-kimi.md; do …        # G7
PRESENT corpus/knowledge/unreal-mcp/README.md
PRESENT corpus/knowledge/unreal-mcp/PROVENANCE.md
PRESENT corpus/knowledge/unreal-mcp/adaptation-kimi.md

$ bash /tmp/s48/runtime-claim-scan.sh reports/round-101 corpus/knowledge/unreal-mcp   # G4
RUNTIME_NAMED_FILES=26 LABELED_OR_DISCLAIMED=26 UNLABELED=0
STEP=PASS                                          exit=0
```

G7 matters for C3 specifically: at protocol-write time both `PROVENANCE.md` and
`adaptation-kimi.md` were MISSING and the protocol declared that step failing. Both are now
present, so G7 is closed.

### 2.4 Negative controls — the checks are not vacuous

The control file plants one non-existent path and one out-of-range line — the protocol's §7
pair, written below **deliberately defanged** (path and line number separated, so this
report's own text cannot match the checker's pointer regex and re-contaminate the whole-tree
gate; see F5, where I hit exactly that failure with my first draft and fixed it):

```
$ bash /tmp/s48/pointer-check.sh /tmp/s48/n3 corpus/knowledge/unreal-mcp
MISSING-PATH /tmp/s48/n3/a.md :: <nonexistent upstream path>, line 3
LINE-OOR /tmp/s48/n3/a.md :: <upstream README>, line 9999 (max 112)
POINTERS=42 UNRESOLVED=2
STEP=FAIL                                          exit=1

$ bash /tmp/s48/linkcheck.sh /tmp/s48/n2
md_files=1 links_total=1 relative=1 absolute=0 fragment_only=0 broken=1
BROKEN /tmp/s48/n2/a.md -> ./nope.md
STEP=FAIL                                          exit=1
```

The control file itself is written by this seat under `/tmp`, never in the repo. The real
strings are the protocol's §7 pair; anyone re-running this should take them from there.

Both controls fail as designed, so the two PASSes above carry information.

---

## 3. The required 5-pointer hand spot-check (resolve *and* content)

A pointer can resolve and still point at the wrong content, so the seat's required sample
was run by printing the cited line, not by trusting the resolver.

```
### SPOT-CHECK 1: upstream/hooks/hooks.json:6          (row 3, hook matcher)
        "matcher": "startup|resume|clear",

### SPOT-CHECK 2: upstream/hooks/unreal-context.sh:84   (row 4, hook output shape)
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$escaped_context"

### SPOT-CHECK 3: upstream/README.md:92                 (row 13, --dangerously-skip-permissions)
**`--dangerously-skip-permissions` removes the per-tool approval gate.** …

### SPOT-CHECK 4: ~/.kimi-code/config.toml:2932-2937    (row 2, live [[hooks]] precedent)
[[hooks]]
event = "Notification"
matcher = "task\\.completed"
command = "notify-send -a 'Kimi Code' 'Background task completed' …"
timeout = 5

### SPOT-CHECK 5: kimi strings line 1743845              (row 11, resolveMcpJsonPaths)
async function resolveMcpJsonPaths(input) {
```

**All five match the row they support.** Spot-check 1 is the exact matcher string the row
names; 2 is the exact `hookSpecificOutput`/`additionalContext` payload the row says Kimi
cannot read; 3 is the exact flag the row maps; 4 is a real `[[hooks]]` block of the same
shape the row claims Kimi accepts; 5 is the function whose body the row quotes.

Independent corroboration beyond the sample:

- **Row 4's quoted schema is in the binary verbatim.** The row prints a `HookSpecificOutputSchema`
  / `HookJsonOutputSchema` source block. I re-extracted it myself:
  ```
  $ strings -n 3 ~/.kimi-code/bin/kimi > /tmp/s48_strings3.txt   # 2644877 lines
  $ grep -n "HookSpecificOutputSchema" /tmp/s48_strings3.txt | head -1
  1841245:var DEFAULT_TIMEOUT_SECONDS, KILL_GRACE_MS$1, OptionalStringSchema, HookSpecificOutputSchema, HookJsonOutputSchema;
  ```
  and `grep -c additionalContext` → `0`, `grep -c hookEventName` → `1` — the two counts the
  row's argument rests on. My extraction is **byte-identical** to the doc's own
  `/tmp/kimi_strings.txt` (`cmp` → BYTE-IDENTICAL), and the BuildID in the ELF matches the
  one the file declares (`file … BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19`,
  `kimi --version` → `2.2.0`), so the invalidation rule the file states for those pointers is
  satisfied today.
- **The docs pointers resolve to live pages that confirm the rows.** `customization/plugins.html`
  fetched: it contains the plugin-manifest section listing exactly the fields row 1/8 names
  (`sessionStart.skill`, `skillInstructions`, `systemPrompt`, `systemPromptPath`, `mcpServers`,
  `hooks`, `commands`), the `/plugins install|marketplace|list|info|enable|disable|remove|reload`
  command table of rows 6/7, and the sentence row 9 quotes — "Plugin 目前按用户安装，对所有项目
  生效，暂不支持项目级安装范围" ("plugins are installed per-user … project-level installation
  scope is not yet supported"). `customization/hooks.html` fetched: it has the **Return Values**
  table (exit `0` allow / `2` block / other fail-open) that row 5 names, the `SessionStart`
  matcher column reading `startup` 或 `resume` that row 3 names, and the same
  `hookSpecificOutput{permissionDecision, permissionDecisionReason}` output shape row 4 names.
- **Every internal `§` reference resolves.** Refs used: `§3.1 §3.2 §3.3 §3.4 §3.5 §4 §4.1 §4.2
  §4.3 §4.4 §6`; headings present: `## 1 … ## 7`, `### 3.1–3.5`, `### 4.1–4.5`. All present.

---

## 4. Findings

### F1 — LOW, actionable: row 5's primary pointer is off by one

Row 5 (`Hook exit code semantics`) cites `upstream/hooks/unreal-context.sh:47`. Line 47 is
the closing `fi`; the `exit 0` the row is about is on **line 46**:

```
$ sed -n '46,47p' corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
  exit 0
fi
```

The pointer resolves and is in range, so the mechanical gate cannot see this — it is exactly
the "resolves but points at the wrong content" case the protocol warns about. The row's
secondary pointer (`docs customization/hooks.html §Return Values`) is correct and carries the
actual semantics, so the row is not unsupported; only its upstream anchor is one line low.
Fix: `:46`.

### F2 — LOW, documentation: §3.4's inline command disagrees with its own line numbers

§3.4 shows the command `strings -n 6 … | grep -n 'KIMI_PLUGIN_ROOT_PATH\|KIMI_PLUGIN_DIR_PATH'`
and prints `# 1832505:` / `# 1832506:`. Run as written, `-n 6` yields only **1 113 663** lines
(observed), so line 1832505 does not exist and the command cannot produce that output. The
cited numbers are correct for a `strings -n 3` extraction (2 644 877 lines), which is what
§4's preamble documents as the file actually used:

```
$ strings -n 6 …/kimi | wc -l
1113663
$ sed -n '1832505p;1832506p' /tmp/s48_strings3.txt   # -n 3 extraction
	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
	KIMI_PLUGIN_DIR_PATH = ".kimi-plugin/plugin.json";
```

Every cited binary line number in the file (1832505, 1832506, 1743845) is valid under `-n 3`.
The fix is to write `-n 3` in §3.4 (or note that §4's extraction is the one in force).

### F3 — INFO: the docs pointers have no stated base URL inside the file

The 8 docs pointers are written as bare site paths (`customization/plugins.html`,
`customization/hooks.html`, `customization/mcp.html`, `configuration/config-files.html`).
The file states no base URL, so a reader cannot resolve them from the document alone. They are
recoverable because the binary itself carries the full form —
`https://www.kimi.com/code/docs/kimi-code-cli/customization/plugins.html` appears in the
strings — and the pages fetch and confirm the rows (§3). Not a resolvability defect, but the
rows would be self-contained with the base prefixed. `configuration/config-files.html` is the
weakest of the four: the binary's occurrence of that filename is under a
`moonshotai.github.io/kimi-code/en/` prefix, i.e. a different host from the
`www.kimi.com/code/docs/kimi-code-cli/` prefix the other three share.

### F4 — INFO: 0 `unproven-runtime` rows in the table is correct, not a gap

The table has 6 `verified-here` and 9 `static-only` and **no** `unproven-runtime` row, which
could read as the class being unused. It is not: the editor-dependent claims are collected in
§6 "Unproven-runtime register" as a separate 5-row table, each stating what would settle it,
and §5's policy defines the three admissible classes explicitly. That is the honest shape —
the adaptation *table* is about Claude→Kimi mechanism mapping, none of which needs a live
editor; the editor-dependent claims are registered separately. Worth keeping, since the C2
cards use `unproven-runtime` as a card label and the two surfaces should not be conflated.

### F5 — INFO, self-inflicted-then-fixed: any file quoting the controls re-contaminates G6

`pointer-check.sh` excludes only the protocol file itself
(`self=reports/round-101/r101-verification-protocol.md`) from its scan. Any *other* file that
contains the protocol's §7 negative-control strings as literal text makes the whole-tree gate
report `UNRESOLVED=2` — a false positive, since those are documentation, not pointers.

I hit this twice. First on a sibling draft (`reports/round-101/r101-report.md`, which at that
moment quoted both control strings); it was later edited to remove them. Then **on my own
first draft of this report**, whose §2.4 reproduced the control output verbatim:

```
$ bash /tmp/s48/pointer-check.sh reports/round-101 corpus/knowledge/unreal-mcp
MISSING-PATH reports/round-101/r101-reviewer-c3.md :: <control string>
LINE-OOR reports/round-101/r101-reviewer-c3.md :: <control string>
POINTERS=84 UNRESOLVED=2
STEP=FAIL
```

Fixed by defanging the strings in this report (§2.4 shows placeholder text instead). On the
final bytes, the gate is clean and only the protocol file carries the control strings:

```
$ grep -rln "upstream/nope" reports/round-101/
reports/round-101/r101-verification-protocol.md

$ bash /tmp/s48/pointer-check.sh reports/round-101 corpus/knowledge/unreal-mcp
POINTERS=84 UNRESOLVED=0
STEP=PASS
```

Two takeaways for the close-out verifier. (1) The exclusion list is a live dependency, not a
fixed property: a review report that quotes the controls will break the gate it is describing,
so quote them defanged. (2) The C3 artifact itself is unaffected by all of this — run alone it
is `POINTERS=57 UNRESOLVED=0 STEP=PASS` regardless of what the sibling reports do.

---

## 5. Residual risk and verification gaps

- **F1 is the only content defect**, and it is one line in one row whose semantics are also
  carried by a correct secondary pointer. Nothing else I checked resolves to the wrong content.
- **The `verified-here` label rests on the author's pasted probe transcripts.** I verified the
  *pointers* those rows cite and the binary constants they quote, and I confirmed the upstream
  hook really does emit `additionalContext` (spot-check 2) and that Kimi's parser really has no
  such field (§3). I did **not** re-run the author's live `kimi` session probes (§3.1–3.3); a
  full re-run would need a live model provider and a throwaway `KIMI_CODE_HOME`, and the rows'
  *claims* are consistent with every static fact I could independently check. This is the
  standard limit of a pointer review versus a runtime review.
- **The docs pages are live web content.** They resolved today; a docs redesign would break the
  8 docs pointers without touching the artifact. The file's own invalidation rule covers the
  binary pointers and the `upstream/` pin but not the docs pages — a small gap worth a line in
  §5's invalidation rule.
- **I did not audit the C2 cards' labels** beyond running the shared G3/G4 scanners
  (`CARDS=13 EXPECTED=13 BAD=0`, `UNLABELED=0`), which are C2's gates, not C3's. They are
  reported here only because C3's §6 register and the C2 card labels must not drift apart (F4).

## 6. Receipts used by this seat

- Check scripts, materialised verbatim from `r101-verification-protocol.md` §0: `/tmp/s48/{label-scan,runtime-claim-scan,pointer-check,linkcheck}.sh`.
- My own independent resolver and row parser: `/tmp/s48-pointers.py`, plus the inline
  `python3` blocks quoted above.
- Re-extracted binary strings: `/tmp/s48_strings3.txt` (2 644 877 lines, `cmp` BYTE-IDENTICAL
  to the doc's `/tmp/kimi_strings.txt`), `/tmp/s48_strings6.txt` (1 113 663 lines).
- Negative controls: `/tmp/s48/n2/`, `/tmp/s48/n3/`.
- Reviewed bytes: `corpus/knowledge/unreal-mcp/adaptation-kimi.md`
  sha256 `e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981`, 363 lines.
- Docs pages fetched: [customization/plugins.html](https://www.kimi.com/code/docs/kimi-code-cli/customization/plugins.html),
  [customization/hooks.html](https://www.kimi.com/code/docs/kimi-code-cli/customization/hooks.html).

*Recommendation (advisory only, this seat does not admit): C3 is supported — every row carries
a resolvable pointer and the gates G4/G5/G6/G7 are green on the final bytes. Correct the row-5
off-by-one (F1) and the §3.4 `strings -n 6` command (F2); F3–F5 are improvements, not blockers.*
