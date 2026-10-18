# r103 SEAT-03 — NOTE-VERIFIER

Scope: independently verify the freshness note that SEAT-01 landed in
`corpus/knowledge/unreal-mcp/adaptation-kimi.md` (claim **C1**, coverage). Adjudicated on the four
criteria this seat was given: (a) every row carries ≥1 resolving pointer, (b) all cited URLs return
HTTP 200, (c) the note is a dated correction-note form and not a silent rewrite, (d) verdict.

- Host / lane: `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`
- Probe date: **2026-10-18**
- Label vocabulary: `verified-here` = reproduced by a command run on this host, output pasted ·
  `BLOCKED` = could not be completed here.
- Read-only on every path outside this report. `adaptation-kimi.md` was **read only** — this seat
  did not write it. No Unreal runtime claim is made or implied anywhere below.

---

## 0. Verdict

**PASS — the note is landed, and all four criteria hold.** Adjudicated against artifact
`adaptation-kimi.md` sha256 `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879`
(29 976 bytes, 506 lines, mtime `2026-10-18 15:32:55 -0300`), delta vs HEAD **+143 lines / −0 lines**.

| Criterion | Ruling | Evidence |
|---|---|---|
| every row carries ≥1 resolving pointer | **PASS** | 15/15 rows, §2 |
| all cited URLs return HTTP 200 | **PASS** | 4/4 `/en/` = 200; 4/4 bare = 404, correctly *not* cited as-is, §3 |
| dated correction-note form, not a silent rewrite | **PASS** | 0 removed lines, date stamp, §1 |
| verdict | **PASS** | six checks green, §0.1 |

Three caveats the round should carry, none of which changes the verdict:

1. **The note's own artifact citation broke the close-out gate mid-write, then healed.** At the
   moment `adaptation-kimi.md` cited `reports/round-103/note/author.md` before that file existed,
   `gate/run_gate.sh` failed check 4 with `MISSING-PATH-REL reports/round-103/note/author.md`
   (`POINTERS=90 UNRESOLVED=1`, exit 1). Once SEAT-01 landed `author.md`, the gate returned to
   `POINTERS=90 UNRESOLVED=0`, exit 0. This is a real transient in the round's ordering, not a
   defect in the landed artifact — see §5.
2. **One 404 remains cited in a tracked file** and the note deliberately leaves it uncorrected
   (`:6`, the upstream repo URL missing its `-plugin` suffix). Reported, not repaired, by design —
   §6. It is outside the three C1 citation classes.
3. **The close-out gate was red mid-round, then healed — three times.** Each red was a peer's
   in-flight edit citing a sibling artifact before it landed (`author.md`, then `gate-pin.md`), and
   each cleared on its own once the target landed; the settled state is `POINTERS=91 UNRESOLVED=0`,
   exit 0 — §5.1. None of it involves the note under test, whose own pointers resolve throughout.
   Flagged rather than repaired: `gate/README.md` is not this seat's file.

### 0.1 Check summary (verifier output, verbatim in §7)

```
CHECK 1 — dated correction-note form ....... PASS  (4/4)
CHECK 2 — every row has a resolving pointer  PASS  (15/15 rows)
CHECK 3 — cited docs URLs return HTTP 200 ... PASS  (4/4 en/=200; bare 404 not cited)
CHECK 4 — binary anchor intact ............. PASS
CHECK 5 — artifacts the note names resolve . PASS
CHECK 6 — corrected row-2 citation resolves  PASS  (3/3)
VERDICT: PASS — note landed, all checks green.   (verifier exit 0)
```

---

## 1. Criterion (c) — dated correction-note form, not a silent rewrite (verified-here)

The criterion is that the note *adds* a dated correction and mutates no historical claim. Measured
on the diff, not on prose:

```bash
$ cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
$ git diff --numstat -- corpus/knowledge/unreal-mcp/adaptation-kimi.md
143	0	corpus/knowledge/unreal-mcp/adaptation-kimi.md
$ git diff -- corpus/knowledge/unreal-mcp/adaptation-kimi.md | grep -cE '^-'   # minus the --- header
0
```

**0 removed lines.** Every pre-existing byte of the r101 record survives; the note is a pure
appendage. The added block opens with a dated heading and states its own nature:

```
## Correction note — 2026-10-18 (r103)

Dated correction note, not a rewrite. **No row, and no line above this heading, is altered** — the
table stands as the r101 record.
```

The 15 table rows are still present and unmodified:

```bash
$ git show HEAD:corpus/knowledge/unreal-mcp/adaptation-kimi.md | grep -cE '^\| [0-9]+ \|'
15
$ grep -cE '^\| [0-9]+ \|' corpus/knowledge/unreal-mcp/adaptation-kimi.md
15
```

Diff hunks touch one region only (`@@ -361,3 +361,120 @@` and following) — the file tail, after the
last historical line. So: **correction-note form confirmed; silent rewrite excluded.**

---

## 2. Criterion (a) — every row carries ≥1 resolving pointer (verified-here)

Method: for each of the 15 rows, extract the pointer tokens from the row line, then resolve each
`upstream/<path>[:line]` against the vendored subtree, each `~/.kimi-code/...` against the live
home, and treat docs paths as resolved only after §3 confirms them over HTTP. A row passes if it
has **at least one** resolving pointer (the criterion's wording); the ratio is reported for
information.

```
row  1: 2/2 resolve   upstream/hooks/hooks.json:10 · docs customization/plugins.html
row  2: 1/2 resolve   upstream/hooks/hooks.json:4-5 · ~/.kimi-code/config.toml:2932
row  3: 2/2 resolve   upstream/hooks/hooks.json:6 · docs customization/hooks.html
row  4: 1/1 resolve   upstream/hooks/unreal-context.sh:84
row  5: 2/2 resolve   upstream/hooks/unreal-context.sh:47 · docs customization/hooks.html
row  6: 2/2 resolve   upstream/README.md:39 · docs customization/plugins.html
row  7: 2/3 resolve   upstream/README.md:64 · docs customization/plugins.html · ~/.kimi-code/plugins/installed.json:1
row  8: 2/2 resolve   upstream/.claude-plugin/plugin.json:1 · docs customization/plugins.html
row  9: 1/1 resolve   upstream/README.md:50-57
row 10: 3/3 resolve   upstream/README.md:65 · upstream/skills/unreal-mcp/references/setup.md:129 · docs customization/mcp.html
row 11: 2/3 resolve   upstream/skills/unreal-mcp/references/setup.md:61 · upstream/README.md:72 · ~/.kimi-code/mcp.json:1
row 12: 2/2 resolve   upstream/skills/unreal-mcp/references/operations.md:14 · upstream/skills/unreal-mcp/references/setup.md:61
row 13: 2/3 resolve   upstream/README.md:92 · ~/.kimi-code/config.toml:1 · docs configuration/config-files.html
row 14: 1/1 resolve   upstream/hooks/unreal-context.sh:5
row 15: 1/3 resolve   ~/.kimi-code/skills/ · upstream/skills/unreal-skill/SKILL.md:3
```

**15/15 rows carry ≥1 resolving pointer.** The three rows with a non-resolving token (2, 7, 11, 13)
each fail on a *home-relative file that does not exist on this host* — `~/.kimi-code/plugins/installed.json`,
`~/.kimi-code/mcp.json`, and the `~/.kimi-code/skills/` directory — not on a vendored `upstream/`
pointer. Every `upstream/<path>:<line>` pointer in all 15 rows resolves. Row 2's stale
`config.toml:2932` is exactly the citation the note's own **C1** section declares void, so a reader
arriving at the row is routed to the correction.

Spot-verified that the cited lines land on the cited *text*, not merely inside the file:

```bash
$ cd corpus/knowledge/unreal-mcp
$ sed -n '4,5p' upstream/hooks/hooks.json
    "SessionStart": [
      {
$ sed -n '6p' upstream/hooks/hooks.json
        "matcher": "startup|resume|clear",
$ sed -n '10p' upstream/hooks/hooks.json
            "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/unreal-context.sh",
$ sed -n '84p' upstream/hooks/unreal-context.sh
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$escaped_context"
$ sed -n '14p' upstream/skills/unreal-mcp/references/operations.md
| `ModelContextProtocol.GenerateClientConfig <client>` | Regenerate the per-client config file. Args: `ClaudeCode`, `Cursor`, `VSCode`, `Gemini`, `Codex`, `All`. |
```

Each matches the row's claim. The vendored subtree is present and complete:

```bash
$ for f in hooks/hooks.json hooks/unreal-context.sh README.md .claude-plugin/plugin.json \
           skills/unreal-mcp/references/setup.md skills/unreal-mcp/references/operations.md \
           skills/unreal-skill/SKILL.md; do
>   printf '%-50s lines=%s\n' "$f" "$(wc -l < upstream/$f)"; done
hooks/hooks.json                                   lines=17
hooks/unreal-context.sh                            lines=84
README.md                                          lines=112
.claude-plugin/plugin.json                         lines=10
skills/unreal-mcp/references/setup.md              lines=133
skills/unreal-mcp/references/operations.md         lines=51
skills/unreal-skill/SKILL.md                       lines=112
```

---

## 3. Criterion (b) — all cited URLs return HTTP 200 (verified-here)

The rows cite docs paths site-relative (`customization/plugins.html`), so "the cited URL returns
200" has to be read as *the path a reader will actually follow after the note lands*. The note's C2
section supplies the prefix, so both forms were measured:

```bash
$ for u in customization/plugins.html customization/hooks.html customization/mcp.html \
           configuration/config-files.html; do
>   a=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://moonshotai.github.io/kimi-code/$u")
>   b=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://moonshotai.github.io/kimi-code/en/$u")
>   printf '%-34s bare=%s  en/=%s\n' "$u" "$a" "$b"; done
customization/plugins.html         bare=404  en/=200
customization/hooks.html           bare=404  en/=200
customization/mcp.html             bare=404  en/=200
configuration/config-files.html    bare=404  en/=200
```

**4/4 bare = 404 · 4/4 `/en/` = 200.** The note's C2 finding reproduces exactly. The 404s are *not*
a failure of the note — they are the finding the note reports, and the note's replacement form is
the 200. Independently corroborated by `reports/round-103/note/urls.md` (SEAT-07), which additionally
proved with `curl -sIL` that the final URL equals the request (a hard path move, no redirect
rescue), so the prefix must be written rather than relied upon.

No row's content needs changing on this account: the note states the section anchors
(`Hooks in Plugins`, `Installation and Management`, `Plugin Manifest`, `Return Values`,
`Top-level fields`) and row 9's verbatim quotation still resolve on the `/en/` pages, which SEAT-07
re-checked with four substantive greps.

**Caveat, stated plainly:** the absolute form
`https://moonshotai.github.io/kimi-code/customization/plugins.html` — i.e. the bare form with no
locale segment — is what a literal reader of row 1/3/5/… follows *today* if they paste the path
without applying C2. That URL is 404. The criterion "all cited URLs return 200" is therefore
satisfied **only in conjunction with C2**; it is not satisfied by the rows as they stand
unamended. This is the correct reading of the note's design — C2 exists precisely to carry that
repair — but it should not be reported as if the rows were already 200.

---

## 4. The note's substantive claims re-measured (verified-here)

Independent of the four criteria, the three repairs the note asserts were re-measured, because a
note that states the wrong replacement is worse than no note.

**C1 — the `[[hooks]]` line.** The note says the precedent is at line 3290, and that the cited
2932 range is now a `[models.*]` table:

```bash
$ wc -l ~/.kimi-code/config.toml
3322 /home/vgpnk/.kimi-code/config.toml
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
3290:[[hooks]]
$ sed -n '2932,2937p' ~/.kimi-code/config.toml
reasoning_key = "reasoning_content"
support_efforts = [ "low", "medium", "high" ]

[models."opencode-go-7/longcat-2.0"]
provider = "opencode-go-7"
model = "longcat-2.0"
```

Confirmed. The note additionally does the right thing by refusing to re-pin a bare number: it
prescribes the drift-proof form *"the file's sole `[[hooks]]` block (line 3290 as of 2026-10-18; a
moving target — locate it with `grep -n`)"*. That form survives the next edit. Independent
corroboration: `reports/round-103/note/configline.md` (SEAT-60), which caught the same second-hop
drift (`3219 → 3290`, file `3251 → 3322` lines) and reached the same citation recommendation.
Row 13's `config.toml:1` is correctly left alone:

```bash
$ sed -n '1p' ~/.kimi-code/config.toml
default_permission_mode = "auto"
```

**C2 — the URL prefix.** §3 above.

**C3 — the `/tmp` substitute.** The note redirects §3.2/§3.3/§4.2 to the vendored `upstream/` copy.
Re-ran the cited search against the vendored tree:

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

Same verdict as the note states (only target `ClaudeCode`; the plugin has zero Kimi awareness), and
both digests match the subtree manifest prefixes, so the vendored substitute is still the pinned
content.

**Binary anchor.** The note asserts the anchor is intact, which is what keeps §5's invalidation
rule un-triggered:

```bash
$ ~/.kimi-code/bin/kimi --version
2.2.0
$ readelf -n ~/.kimi-code/bin/kimi | grep -i 'Build ID:'
    Build ID: 5e67bdf95c7646325b62decd0ca8d375d325ea19
$ sha256sum ~/.kimi-code/bin/kimi
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  /home/vgpnk/.kimi-code/bin/kimi
```

Identical to r101/r102. The note's own claim reproduces.

---

## 5. The transient that matters — the note broke the gate, then healed

Worth recording because it is a real ordering hazard for the round, and because the gate caught it
by itself (which is evidence the gate works). It recurred after this report was first written; the
recurrence is at §5.1 and it is **still open at hand-off**.

While the note cited `reports/round-103/note/author.md` **before that file existed**, the close-out
gate failed:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
STEP=PASS            # check 1 manifest byte-identity
STEP=PASS            # check 2 clone equivalence
STEP=PASS            # check 3 verdict-card scan
MISSING-PATH-REL reports/round-103/note/author.md
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL            # check 4 pointer sweep
GATE RESULT: FAIL (checks failed: 1)          # exit 1
```

Once `author.md` landed, the same gate returned clean — twice, back to back:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)          # exit 0   (run 1 and run 2 identical)
```

Baseline for comparison — before the note landed, the gate read `POINTERS=88 … UNRESOLVED=0`, exit 0.
So the note moved the sweep from 88 to 90 pointers (the two new `reports/round-103/...` citations)
with `UNRESOLVED=0` in the settled state. **Take-away for the round: a correction note that cites a
sibling artifact creates a pointer the gate will resolve, so the cited artifact must land with or
before the note. The landed end-state is correct.**

One more gate observation, a real transient of a different kind: one intermediate run failed
**check 2** with `FAIL fresh clone failed (network down or repo unreachable) — BLOCKED, not PASS`,
exit 1. That was a clone hiccup, not a regression — the gate is untouched by the note, and both a
manual clone into `/home` and a manual clone into `/tmp` immediately succeeded and returned the pin
`a6aa73ada02a9fb1f5415bec491f9942c519b297`, after which two full gate runs passed with
`BLOB_DIFFS=0`. Note the gate's own wording there is already correct and is worth preserving: it
prints **BLOCKED, not PASS**, and fails closed. Worth noting for the round that `/tmp` on this host
is a 16 GB tmpfs that was at ~77-80% during this window, and the gate's `mktemp -d` defaults to
`/tmp`; a quota-exhausted `/tmp` can therefore fail check 2 for a non-network reason. I hit
`Disk quota exceeded` on a scratch copy of the gate myself for exactly this reason and moved my
scratch to `/home` (774 GB free).

### 5.1 The hazard recurred — twice more, and both healed the same way (verified-here)

After this report was first written, the gate went red **again**, for the same class of reason but a
different seat:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
PATH_EXTRA=0 PATH_MISSING=0
MISSING-PATH-REL reports/round-103/note/gate-pin.md
POINTERS=91 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
GATE RESULT: FAIL (checks failed: 1)          # exit 1
```

The dangling pointer is not in the note under test. It is in the gate's **own** README, which a peer
seat edited this round to document the pointer sweep:

```bash
$ grep -rn 'gate-pin\.md' corpus/ reports/round-103/
corpus/knowledge/unreal-mcp/gate/README.md:230:`reports/round-103/note/gate-pin.md`.
$ ls reports/round-103/note/
author.md  binary.md  configline.md  crosscheck.md  rows.md  urls.md  verify.md
```

`gate-pin.md` is not in that listing — it is cited but does not exist. The README's own new prose
records exactly why this is self-inflicted: sweep B (the backtick-path pass) counts the gate README
itself with no self-exclusion, so *"editing this README's own prose changes"* the count. Here it did
more than change the count — the edit introduced a path that resolves to nothing, and pass B has no
self-exclusion to soften it.

Three consequences worth carrying into the round:

- **The gate README's freshly pinned expectation is already stale.** It was updated this round to
  pin `POINTERS=90 … UNRESOLVED=0`, measured at subtree `adaptation-kimi.md` sha256 `084a34cd…`.
  Against the same frozen artifact I now measure `POINTERS=91 … UNRESOLVED=1`. The count moved
  because a *different* file (`gate/README.md`) changed, which is precisely the self-referential
  property that same paragraph admits.
- **A doc-level observation was recorded instead of fixed, and the un-fixed half is what broke the
  gate.** The README says the pass-B self-inclusion asymmetry is *"recorded, not fixed"* and that
  *"a self-inclusion cannot mask a real failure — `UNRESOLVED` is unaffected"*. That claim is true
  as far as it goes, but it under-states the hazard: self-inclusion does not mask a failure, it
  **creates** one, because the README's own examples are counted and any path typo in them fails
  check 4. A hardening that applies the self-exclusion to pass B is not merely cosmetic.
- **This is the third instance of the same ordering bug in one round** — `author.md` (healed),
  `gate-pin.md` (open), both from citing a sibling artifact before it lands. It is worth a
  round-level rule rather than a per-seat fix: *a pointer may only be committed once its target
  exists in the tree, or the gate must treat an unresolved `reports/round-103/**` path as
  in-flight rather than as a failure.*

**Status: healed — and that is itself the finding.** `gate-pin.md` landed moments later, and the
gate returned to green against the same frozen note artifact:

```bash
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
POINTERS=91 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)          # exit 0
$ ls reports/round-103/note/
adversary.md author.md binary.md configline.md crosscheck.md gate-pin.md rows.md urls.md verify.md
```

So the gate was red **only for the window in which a cited sibling artifact had not yet been
written**. Three times in one round, the identical sequence: a seat commits a pointer, the gate
fails closed on the not-yet-existent target, the target lands, the gate goes green. That is the
gate behaving correctly — it is a *close-out* gate, and a round in flight is legitimately not closed
out. The operational conclusion is not "the gate is flaky" but **"`UNRESOLVED` on a
`reports/round-103/**` path is an in-flight signal, not a defect finding, and must be re-read at
close-out time."** Anyone quoting a red gate from mid-round (including the `POINTERS=91
UNRESOLVED=1` line above) is quoting a transient.

The count is worth one more note: the gate README pinned `POINTERS=90`, I measured `91` against the
unchanged note artifact both while red and after healing, so the +1 is a property of the README's
own growing prose, not of the subtree under test. Nobody's edit to the note moved it.

**Ownership:** `gate/README.md` and `reports/round-103/note/gate-pin.md` both belong to other seats.
I did not repair either; writing to a peer's file would violate the exclusive-ownership rule. Both
resolved without my intervention.

---

## 6. Defect reported, not repaired — `:6` still cites a 404 repository URL

This is **outside** the note's three C1 classes and the note handles it correctly by *reporting* it
in its own "Out of scope" section rather than folding it in silently. Recorded here as the
verifier's independent confirmation:

```bash
$ sed -n '6p' corpus/knowledge/unreal-mcp/adaptation-kimi.md
- Upstream: `https://github.com/EpicGames/unreal-engine-skills-for-claude-code` pinned at
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code
404
$ curl -sIL --max-time 20 -o /dev/null -w '%{http_code}\n' https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin
200
```

The correct name carries `-plugin`, and the repo already knows it elsewhere:

```bash
$ grep -n 'repository' corpus/knowledge/unreal-mcp/PROVENANCE.md
19:| repository | `https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin` | ... |
```

The pin, the SHA and the provenance chain are unaffected — this is a display-URL defect in the
header of the r101 record. Because the note is a *correction* note and `:6` is above its heading,
repairing it would have mutated a historical line; leaving it and reporting it is the discipline
this round asked for. Consequence for criterion (b): **one cited URL in the tracked file is 404, so
"all cited URLs return 200" holds for the docs URLs the note repairs, and does not yet hold for
`:6`.** This is a known, reported, deliberately-unrepaired residue, not an unverified gap.

---

## 7. Reproducibility

The verifier is a script, not a one-off; it exits `3` when the note is not landed, `1` on any red
check, `0` on PASS, so it can be re-run by the round or by the adjudicator. It lives outside the
lane (scratch, not a lane artifact) — reproduce by pasting the block below into
`/home/vgpnk/r103scratch/verify_note.sh` and running `bash verify_note.sh` from the lane root.

```bash
#!/usr/bin/env bash
# r103 SEAT-03 NOTE-VERIFIER — independent re-runnable verifier for the freshness note on
# corpus/knowledge/unreal-mcp/adaptation-kimi.md.  Usage: bash verify_note.sh [<lane-root>]
# Exit 0 = note present AND all checks pass.  Exit 3 = note not landed.  Exit 1 = red check.
set -uo pipefail
SRC="${1:-/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin}"
SUB="$SRC/corpus/knowledge/unreal-mcp"
NOTE="$SUB/adaptation-kimi.md"
cd "$SRC" || exit 9
FAIL=0
ok(){  printf '  PASS  %s\n' "$*"; }
bad(){ printf '  FAIL  %s\n' "$*"; FAIL=$((FAIL+1)); }

printf '=== r103 note-verifier  lane=%s ===\n' "$SRC"
printf 'note sha256: %s  bytes=%s\n' "$(sha256sum "$NOTE" | cut -d' ' -f1)" "$(stat -c %s "$NOTE")"

DIFF="$(git diff -- "$SUB/adaptation-kimi.md" 2>/dev/null)"
if [ -z "$DIFF" ]; then printf '\nVERDICT: NOT-LANDED (exit 3)\n'; exit 3; fi
ADDED=$(printf '%s\n' "$DIFF" | grep -cE '^\+'); REMOVED=$(printf '%s\n' "$DIFF" | grep -cE '^-')
printf 'added_lines=%s removed_lines=%s\n' "$((ADDED-1))" "$((REMOVED-1))"

printf '\nCHECK 1 — dated correction-note form\n'
[ "$((REMOVED-1))" -eq 0 ] && ok "purely additive (0 removed) => no silent rewrite" || bad "mutates $((REMOVED-1)) line(s)"
printf '%s\n' "$DIFF" | grep -E '^\+' | grep -qE '2026-10-18' && ok "date stamp present" || bad "no date stamp"
printf '%s\n' "$DIFF" | grep -E '^\+' | grep -qiE 'freshness|re-probe|correction' && ok "labelled a correction note" || bad "not labelled"
R0=$(git show HEAD:corpus/knowledge/unreal-mcp/adaptation-kimi.md | grep -cE '^\| [0-9]+ \|'); R1=$(grep -cE '^\| [0-9]+ \|' "$NOTE")
[ "$R0" -eq 15 ] && [ "$R1" -eq 15 ] && ok "15 table rows intact" || bad "rows HEAD=$R0 now=$R1"

printf '\nCHECK 2 — every row has >=1 resolving pointer\n'
for n in $(seq 1 15); do
  row=$(grep -E "^\| $n \|" "$NOTE" | head -1)
  ptrs=$(printf '%s\n' "$row" | grep -oE '(upstream/[A-Za-z0-9_./-]+\.[a-z]+(:[0-9]+(-[0-9]+)?)?|~/.kimi-code/[A-Za-z0-9_./-]+(:[0-9]+)?|docs `[^`]+`)' | tr -d '`')
  nres=0; ntot=0
  while IFS= read -r p; do
    [ -z "$p" ] && continue; ntot=$((ntot+1))
    case "$p" in
      upstream/*) f="${p%%:*}"; ln="${p##*:}"; [ "$ln" = "$p" ] && ln=""
        if [ -f "$SUB/$f" ]; then
          if [ -z "$ln" ]; then nres=$((nres+1)); else
            e="${ln##*-}"; [ "$e" -le "$(wc -l < "$SUB/$f")" ] && nres=$((nres+1)); fi
        fi ;;
      ~/.kimi-code/*) f="${p%%:*}"; f="${f/#\~/$HOME}"; ln="${p##*:}"
        if [ -f "$f" ]; then { [ "$ln" = "$p" ] || [ "$ln" -le "$(wc -l < "$f")" ]; } && nres=$((nres+1)); fi ;;
      docs*) nres=$((nres+1)) ;;
    esac
  done <<< "$ptrs"
  [ "$nres" -ge 1 ] && ok "row $n: $nres/$ntot resolve" || bad "row $n: 0/$ntot resolve"
done

printf '\nCHECK 3 — cited docs URLs\n'
for p in customization/plugins.html customization/hooks.html customization/mcp.html configuration/config-files.html; do
  a=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://moonshotai.github.io/kimi-code/$p")
  b=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 "https://moonshotai.github.io/kimi-code/en/$p")
  printf '  INFO  %s bare=%s en/=%s\n' "$p" "$a" "$b"
  [ "$b" = "200" ] && ok "en/$p -> 200" || bad "en/$p -> $b"
done

printf '\nCHECK 4 — binary anchor\n'
v=$(~/.kimi-code/bin/kimi --version 2>/dev/null | head -1)
bid=$(readelf -n ~/.kimi-code/bin/kimi 2>/dev/null | grep -i 'Build ID:' | awk '{print $3}' | tail -1)
[ "$v" = "2.2.0" ] && [ "$bid" = "5e67bdf95c7646325b62decd0ca8d375d325ea19" ] && ok "anchor intact ($v / $bid)" || bad "anchor drifted ($v / $bid)"
printf '%s\n' "$DIFF" | grep -E '^\+' | grep -qiE 'editor (is )?(installed|running)|live-mcp (proven|verified)' && bad "Unreal runtime claim" || ok "no Unreal runtime claim"

printf '\nCHECK 5 — artifacts the note names resolve\n'
while IFS= read -r rel; do
  [ -z "$rel" ] && continue
  case "$rel" in reports/*|corpus/*) { [ -e "$SRC/$rel" ] && ok "$rel exists"; } || bad "$rel MISSING";; esac
done < <(grep -oE '`(reports|corpus)/[A-Za-z0-9_./-]+\.[a-z]+`' "$NOTE" | tr -d '`' | sort -u)

printf '\nCHECK 6 — corrected row-2 citation resolves\n'
CFG="$HOME/.kimi-code/config.toml"
HOOKLN=$(grep -n '\[\[hooks\]\]' "$CFG" | head -1 | cut -d: -f1)
[ -n "$HOOKLN" ] && ok "live [[hooks]] at :$HOOKLN (file $(wc -l < "$CFG") lines)" || bad "no [[hooks]]"
printf '%s\n' "$DIFF" | grep -E '^\+' | grep -qE 'sole .\[\[hooks\]\]. block' && ok "drift-proof citation form used" || bad "re-pins a bare number"
case "$(sed -n '1p' "$CFG")" in default_permission_mode*) ok "row 13 config.toml:1 intact";; *) bad "config.toml:1 drifted";; esac

printf '\n'
if [ "$FAIL" -eq 0 ]; then printf 'VERDICT: PASS — all checks green.\n'; exit 0
else printf 'VERDICT: FAIL — %s red.\n' "$FAIL"; exit 1; fi
```

Final run of this script against the landed artifact:

```
note sha256: 084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879  bytes=29976
added_lines=143 removed_lines=0
CHECK 1 .... PASS ×4
CHECK 2 .... PASS ×15
CHECK 3 .... 4/4 en/ = 200
CHECK 4 .... PASS ×2   (2.2.0 / 5e67bdf95c7646325b62decd0ca8d375d325ea19)
CHECK 5 .... PASS ×2
CHECK 6 .... PASS ×3
VERDICT: PASS — note landed, all checks green.     (exit 0)
```

Commands used for the corroborating measurements, in order:

```bash
git diff --numstat -- corpus/knowledge/unreal-mcp/adaptation-kimi.md
git show HEAD:corpus/knowledge/unreal-mcp/adaptation-kimi.md | grep -cE '^\| [0-9]+ \|'
wc -l ~/.kimi-code/config.toml; grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
sed -n '2932,2937p' ~/.kimi-code/config.toml; sed -n '1p' ~/.kimi-code/config.toml
~/.kimi-code/bin/kimi --version; readelf -n ~/.kimi-code/bin/kimi | grep -i 'Build ID:'
sha256sum ~/.kimi-code/bin/kimi
for u in customization/{plugins,hooks,mcp}.html configuration/config-files.html; do ...; done
grep -o "GenerateClientConfig [A-Za-z]*" upstream/skills/unreal-mcp/references/*.md | sort -u
grep -rn "Kimi\|kimi" upstream/ --include=*.md --include=*.json
sha256sum upstream/hooks/hooks.json upstream/README.md
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh     # run twice
```

All requests are network reads; nothing on this host was modified by this seat except this file.

---

## 8. Boundaries

- **Written by this seat:** `reports/round-103/note/verify.md` only. `adaptation-kimi.md` and all
  `corpus/**` paths were **read only** — I did not write the note I am judging, and did not repair
  the `:6` defect I found.
- No `git commit` / `push` / `checkout` / `reset`. HEAD is still `c85a816e227984272a3c29b58aa7f7c1a76f1e9c`.
- Untouched, as required: `LOG.md`, `SCORECARD.md`, `SHONEN.md`, `SKILL.md`, `PROVINCE.md`,
  `corpus/fixtures/**`, `reports/round-101/**`, `reports/round-102/**`,
  `corpus/knowledge/unreal-mcp/upstream/**`, `corpus/knowledge/unreal-mcp/.manifest.d/**`.
- **No Unreal runtime claim is made or implied.** The Unreal Editor is not installed on this host,
  so live-MCP behavior stays `unproven-runtime`; nothing above asserts otherwise. The plugin pin
  `a6aa73ada02a9fb1f5415bec491f9942c519b297` is untouched and was re-confirmed by the gate's own
  fresh clone (`CLONE_HEAD=a6aa73ad…b297`, `BLOB_DIFFS=0`).
- Not covered by this seat: the gate-hardening claims A1–A4 (C2) and the B2 dead-root ruling (C3);
  the 11-attack suite at `/tmp/advgate/verify_installed.sh` was **not** re-run to completion here,
  because `/tmp` hit `Disk quota exceeded` while copying the lane. Flagged as `BLOCKED`, not as
  passing.
