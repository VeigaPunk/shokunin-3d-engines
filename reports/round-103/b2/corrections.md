# r103 SEAT-29 — CORRECTION-AUDITOR: did the three repairs respect the correction-note discipline?

**Seat:** SEAT-29 CORRECTION-AUDITOR · round r103 · lane `game-dev-3d-shokunin`
**Owned path written:** `reports/round-103/b2/corrections.md` (only). No tracked file was modified by this seat.
**Repo:** `/home/vgpnk/Projects/shokunin/game-dev-3d-shokunin`, HEAD `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last; work `c6f655d`)
**Audit window:** 2026-10-18T18:31Z → 2026-10-18T18:50Z. All three repairs landed inside it, and the two C2 files
kept changing after they did — `run_gate.sh` was rewritten **ten times** and `gate/README.md` twice. Verdicts are
reported against the **final** shas (`run_gate.sh 577c8b54…`, `gate/README.md 834f468d…`), with first-pass
findings shown as superseded rather than deleted.
**Scratch:** `/home/vgpnk/.cache/s29` (not `/tmp` — `/tmp` hit its quota mid-audit, see §7)

**Charge:** audit all three repairs (C1 freshness note, C2 gate hardening A1–A4, C3 dead-root ruling + battery
investigation) against the discipline — *any changed factual/historical claim carries a dated correction note;
mechanical path fixes are documented as such; nothing was silently rewritten* — and give a verdict per file.

**No Unreal runtime claim is made anywhere in this file.** Unreal Editor is not installed on this host and
live-MCP behaviour is unproven by construction; nothing below is evidence of engine behaviour. The commands
below exercise the shell, `git`, `curl`, and Godot 4.7.2 headless.

---

## 0. Verdicts, one table

**Audit was taken in two passes.** The first froze at 18:37:18Z (`run_gate.sh 0c1ca3e1…`); the C2 seats kept
hardening, and a re-verification pass at 18:50Z against the **final** shas (`run_gate.sh 577c8b54…`,
`gate/README.md 834f468d…`) **changed two verdicts upward**. Both passes are shown, because the first-pass
findings were true at the sha they were measured against and two of them were subsequently fixed by their owners.

| # | artifact | sha256 | disposition | discipline verdict |
|---|---|---|---|---|
| C1 | `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | `084a34cd…` | +143 / −0, dated note at line 367 | **PASS** — dated note, append-only, every claim re-derived |
| C2a | `corpus/knowledge/unreal-mcp/gate/run_gate.sh` | `577c8b54…` | +129 / −24 | **PASS** — A1/A2/A3/A4 all implemented and all four falsified by me, §3 |
| C2b | `corpus/knowledge/unreal-mcp/gate/README.md` | `834f468d…` | see §3.4 | **PASS** — dated notes; pin re-measured to `101`; A1–A4 and the A4 residual documented, §3.4 |
| C3a | `corpus/artifacts/glb-r12/README.md` | `d87774dc…` | 3/3 lines | **PASS with declaration outside the file**, §4.2 |
| C3b | `corpus/artifacts/unity-r19/README.md` | `12c4abd1…` | 2/2 lines | **PASS with declaration outside the file**, §4.2 |
| C3c | `corpus/fixtures/three/README.md` | `19ad2c8c…` | 17/17 lines | **PASS with declaration outside the file**, §4.2 |
| C3d | battery row `phys3d_joints_free_ops` | — | investigation only | **PASS (investigation)** — and it **falsifies a standing r102 claim**, §5 |

**Superseded first-pass verdicts, disclosed rather than quietly replaced.** At the 18:37 freeze I recorded
C2a as *"A4 partial"* and C2b as *"FAIL (drift)"*. The A4 finding was **my own harness's fault** and is withdrawn
(§3.3); the README drift was real at that sha and was fixed by its owner before the re-verification pass (§3.4).
The correction-note discipline itself was never violated in either pass.

**Headline:** no historical claim was silently rewritten. Every dated correction note that exists is correctly
formed — the two that were written during the round (C1's freshness note, C2b's pin correction) and the two that
were added in response to first-pass findings. The only defect that survives to the final shas is **not** a
discipline violation: the three C3 READMEs carry no in-file note at all, so their declaration lives entirely in
external reports (§4.2).

---

## 1. Method, and why the sha is on every row

The gate file was rewritten **ten times** inside the audit window (`412d1b84` → `1305485d` → `b5fecfc1` →
`1a06b031` → `55a76cf8` → `ff2c26c0` → `510e186c` → `f23f3c8c` → `abc0ddde` → `0c1ca3e1` → `577c8b54`), and
`gate/README.md` twice. Several early control runs were **invalidated mid-flight** by that churn and are reported
as superseded, not as findings. Every result below names the sha it was measured against; the **final** shas are
`run_gate.sh 577c8b54…` and `gate/README.md 834f468d…`, and §3's verdicts are re-verified against them.

### 1.1 The harness error that produced a false finding, stated plainly

My first scratch trees were built by `cp -r corpus/knowledge/unreal-mcp <scratch>/sub`. That layout gives sweep B
a repo root at `<scratch>` containing **nothing** — no `corpus/`, no `reports/`. Sweep B then reports ~26
spurious `MISSING-PATH-REL` lines and every scratch run is red regardless of the mutation under test. I noticed
the artefact and assumed it was harmless because I keyed on mutation-specific signals.

**It was not harmless.** It is exactly why I first reported A4 as *"the exit-2 state is unreachable whenever
anything else is red"*: the "other red check" was my own harness. The README of the gate now records the same
bug from the other side — `REPO` was reused for both the clone URL and the repo root, so a caller overriding the
clone target (`REPO=<url> run_gate.sh`, the natural way to test A4) silently repointed sweep B. My workaround
(`sed -i 's|^REPO=.*|…|'` on the scratch copy) was exposed to the same class of mistake.

The re-verification pass builds scratch trees **correctly rooted**: a real directory per case, with `reports/` and
every sibling of `corpus/knowledge/unreal-mcp` symlinked back to the lane repo, and only the subtree copied. On
that harness the clean control is green (`rc=0`, `GATE RESULT: PASS`) and every mutation produces exactly its own
signal. All §3 results below come from that harness.

### 1.2 Method

Each case is a real scratch repo root, the subtree copied in, the mutation planted, and the gate run from the
copy. The clean control is run first and must be green — without that, a red result proves nothing. Signals used:
`LINE-OOR`, `card-name-*`, `CARDS=`/`CENSUS`, `NAME_SET`, `STEP=BLOCKED`, `GATE RESULT`, and the exit code.

---

## 2. C1 — `adaptation-kimi.md`: PASS

### 2.1 The note is dated, and it is a note, not a rewrite

```
$ git diff --numstat -- corpus/knowledge/unreal-mcp/adaptation-kimi.md
143	0	corpus/knowledge/unreal-mcp/adaptation-kimi.md
$ git show HEAD:corpus/knowledge/unreal-mcp/adaptation-kimi.md | sha256sum
e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981  -
$ head -363 corpus/knowledge/unreal-mcp/adaptation-kimi.md | sha256sum
e0f8ca9b757d645221cc01d4508098b9c48ffc7a93619754d188a4fb67b4b981  -
```

Zero deletions. The first 363 lines hash to the **whole-file pre-edit digest**, so the entire r101 table is
byte-identical to HEAD. The note is headed:

```
367:## Correction note — 2026-10-18 (r103)
```

It opens *"Dated correction note, not a rewrite. **No row, and no line above this heading, is altered**"* — which
the two hashes above independently confirm.

### 2.2 Every factual claim in the note, re-derived by this seat

The note fixes three stale citation classes. All three reproduce:

**(a) the config line moved — and moved again.** The brief says "~line 3219 — verify"; r102 measured 3219; the
note measures **3290**. Both are right at their own moment:

```
$ wc -l ~/.kimi-code/config.toml
3322 /home/vgpnk/.kimi-code/config.toml
$ grep -n '\[\[hooks\]\]' ~/.kimi-code/config.toml
3290:[[hooks]]
$ sed -n '2932,2937p' ~/.kimi-code/config.toml
reasoning_key = "reasoning_content"
support_efforts = [ "low", "medium", "high" ]
                                    ← blank
[models."opencode-go-7/longcat-2.0"]
provider = "opencode-go-7"
model = "longcat-2.0"
$ sed -n '1p' ~/.kimi-code/config.toml
default_permission_mode = "auto"
```

The cited range is a `[models.*]` table, exactly as the note says; the sole `[[hooks]]` block is at 3290 with the
field vocabulary row 2 depends on (`event`/`matcher`/`command`/`timeout`) and event `Notification`, not
`SessionStart`. Row 13's `config.toml:1` is unaffected. The note's decision to give the **drift-proof** form
("the file's sole `[[hooks]]` block, located with `grep -n`") with 3290 as a dated parenthetical is the right call —
this is a file the operator edits continuously (mtime 2026-10-18 14:50, i.e. mid-round).

**(b) the doc URLs need `/en/`.** All four root paths 404; all four prefixed paths 200:

```
$ for u in customization/plugins.html customization/hooks.html customization/mcp.html configuration/config-files.html; do
    printf 'root %s -> ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' --max-time 15 "https://moonshotai.github.io/kimi-code/$u"
    printf 'en   %s -> ' "$u"; curl -s -o /dev/null -w '%{http_code}\n' --max-time 15 "https://moonshotai.github.io/kimi-code/en/$u"; done
root customization/plugins.html -> 404      en   customization/plugins.html -> 200
root customization/hooks.html -> 404        en   customization/hooks.html -> 200
root customization/mcp.html -> 404          en   customization/mcp.html -> 200
root configuration/config-files.html -> 404 en   configuration/config-files.html -> 200
```

**(c) the `/tmp` pointer → the vendored copy.** The note's replacement commands reproduce against the vendored
tree, and the digests it prints match the pinned manifest:

```
$ cd corpus/knowledge/unreal-mcp
$ grep -rn "Kimi\|kimi" upstream/ --include=*.md --include=*.json ; echo "exit=$?"
exit=1
$ sha256sum upstream/hooks/hooks.json upstream/README.md
259124f0631b7d4b92e9e744003e8798b910c00dac201656b97906b3b5ebdc0c  upstream/hooks/hooks.json
483693ad0e14d027525d25c3d3eb4883e774b2f8150013181f9625e2dd46b40e  upstream/README.md
```

Both prefixes appear verbatim in `.manifest.d/audit-reference.sha256`, so the "vendored copy is still the pinned
content" claim is anchored, not asserted. The binary anchor the note relies on to argue §5's invalidation rule is
*not* triggered is also intact:

```
$ kimi --version
2.2.0
$ file $(readlink -f $(which kimi)) | grep -o 'BuildID\[sha1\]=[0-9a-f]*'
BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19
$ sha256sum $(readlink -f $(which kimi))
8ee7405d82958f0a50a3aab0773aba9e01057978bad93ba379eaf89e5b6111af  /home/vgpnk/.kimi-code/bin/kimi
```

All three values match the note.

### 2.3 One coupling this seat flags (not a discipline violation)

The note's preamble points at its evidence file by path: ``in `reports/round-103/note/author.md`.`` For ~28
seconds that file did not exist, and the gate's own sweep B caught it:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E 'MISSING|UNRESOLVED'
MISSING-PATH-REL reports/round-103/note/author.md
POINTERS=90 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1      → GATE RESULT: FAIL, rc=1
```

The file landed at 15:33:45 and the gate returned to green. **No edit is required** — but note the new coupling:
the byte-pinned subtree's prose now cites round-report paths that exist only in the worktree, and by the end of the
round five such citations exist (the C2 seats' own hardening reports added two more). This is what §6(a) measures
as a property change.

---

## 3. C2 — gate hardening A1–A4: all four PASS

Re-verified against the **final** sha `run_gate.sh 577c8b54…` on the correctly-rooted harness (§1.1). The clean
control is green first; each mutation then produces exactly its own signal and nothing else.

```
=== clean ===                      rc=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
GATE RESULT: PASS (checks failed: 0)

=== A1 ===                         rc=1
LINE-OOR <scratch>/…/README.md :: upstream/README.md:1-9999 (max 112)
GATE RESULT: FAIL (checks failed: 1)

=== A2 ===                         rc=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
GATE RESULT: PASS (checks failed: 0)

=== A3 ===                         rc=1
FAIL card-name-missing sequencer.md
FAIL card-name-extra sequence-typo.md
NAME_SET=BAD NAME_BAD=2
GATE RESULT: FAIL (checks failed: 1)

=== A4 ===                         rc=2
CHECK 2 BLOCKED (network)
BLOCKED fresh clone could not complete — upstream unreachable, nothing compared
BLOCKED exit 2 is not a verdict: the vendored bytes are UNCHECKED, not divergent
STEP=BLOCKED
GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)
```

### 3.1 A1 — every endpoint of `:a-b` / `:a,b` is now validated: PASS

The old extraction matched only the first number of a range; the new one matches the whole tail and loops:

```
$ grep -n "A1 (SEAT-09, r103)" -A 6 corpus/knowledge/unreal-mcp/gate/run_gate.sh
# A1 (SEAT-09, r103): validate EVERY endpoint. `:a-b` ranges and `:a,b` lists
for ln in $(printf '%s' "$rest" | tr ',-' '  '); do
  P_TOTAL=$((P_TOTAL+1))
  ...
done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" "$f" | sort -u)
```

My control is the exact mutation the r102 fold-spec said the gate could not see — a planted
`upstream/README.md:1-9999`, which under the old gate resolved as in-range `:1` and stayed green. It now produces
`LINE-OOR … (max 112)` on the **tail** endpoint. **A1 is fixed and the fold-spec's own falsifiable acceptance is
met.**

### 3.2 A2 — the prose-hijack is ignored: PASS

A2 anchors the declaration to the five real label shapes instead of taking the first token-bearing line:

```
$ grep -n "LABEL_RE=" corpus/knowledge/unreal-mcp/gate/run_gate.sh
211:LABEL_RE="^[[:space:]]*\*\*(Label|Verdict)( label)?:\*\*[[:space:]]*\`?($TOKENS)|…"
```

Control — the exact sentence from the r102 fold-spec, planted above a card's declaration:

```
$ sed -i '4i This card is emphatically not `verified-here`; nothing was observed.' \
      <scratch>/A2/executability/editor-general.md
$ bash <scratch>/A2/gate/run_gate.sh | grep -E 'CARDS=|CENSUS'
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
```

Under the r102 gate this sentence was accepted as the declaration and produced `FAIL label-unmarked` with
`BAD=1`. It is now correctly ignored and the census holds at 12/1/0. **A2 is fixed.**

### 3.3 A3 — the card-name set is compared in both directions: PASS

```
$ grep -n "PINNED_CARD_NAMES=" corpus/knowledge/unreal-mcp/gate/run_gate.sh
41:PINNED_CARD_NAMES='actors-scene animation-controlrig assets-content blueprints editor-general
   gameplay-gas materials meshes-textures scripting-programmatic sequencer testing-automation
   ui-umg-slate vfx-niagara-dataflow'
```

Control — the rename that keeps the count at 13:

```
$ mv <scratch>/A3/executability/sequencer.md <scratch>/A3/executability/sequence-typo.md
$ bash <scratch>/A3/gate/run_gate.sh | grep -E 'card-name|NAME_SET'
FAIL card-name-missing sequencer.md
FAIL card-name-extra sequence-typo.md
NAME_SET=BAD NAME_BAD=2
```

Both directions are caught. **A3 is fixed.**

### 3.4 A4 — BLOCKED is a real third state with exit 2: PASS

The BLOCKED branch exists and is declared in code:

```
$ grep -n "CHECK 2 BLOCKED\|STEP=BLOCKED\|exit 2\|GATE_REF" corpus/knowledge/unreal-mcp/gate/run_gate.sh
113:#   A4 (SEAT-09, r103) — BLOCKED is a THIRD state, not a flavour of FAIL.
174:    printf 'CHECK 2 BLOCKED (network)\n'
181:if [ "$C2_BLOCKED" -eq 1 ]; then
182:  printf 'STEP=BLOCKED\n\n'
288:if [ "$C2_BLOCKED" -eq 1 ] && [ "$FAILS" -eq 0 ]; then
289:  printf 'GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)\n'
290:  exit 2
```

Control — an unreachable `REPO` with no `GATE_REF`, on an otherwise-clean tree: `rc=2` and
`GATE RESULT: BLOCKED (checks failed: 0; CHECK 2 could not run)`. The vendored bytes are correctly reported as
*unchecked*, not divergent. `GATE_REF` also works, verified with a real clone at the pin:

```
$ git -C <ref> rev-parse HEAD
a6aa73ada02a9fb1f5415bec491f9942c519b297
$ GATE_REF=<ref> bash <scratch>/A4/gate/run_gate.sh | grep -E 'GATE_REF|CLONE_HEAD|BLOB_DIFFS|STEP='
GATE_REF=<ref> (offline reference; no clone attempted)
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
BLOB_DIFFS=0
STEP=PASS
```

**Withdrawn finding, disclosed in full.** At the first-pass freeze I reported A4 as *PARTIAL*, on the grounds that
`exit 2` is gated on `FAILS -eq 0` and therefore "the third state is unreachable whenever anything else is red".
The premise was false: the "other red check" in every one of those runs was **my own scratch harness**, not a real
defect (§1.1). Rebuilt correctly, the state is reachable and behaves exactly as the fold-spec's acceptance
required. **The A4 finding is withdrawn; A4 passes.**

One residual does remain, and the gate's own README now records it rather than hiding it: when CHECK 2 is BLOCKED
**and** a real check also fails, the run prints `GATE RESULT: FAIL` and exits 1, so the third state is lost in the
mixed case. That is an accurate, documented limitation of the chosen design (`FAILS -eq 0` in the guard), not a
misdescription, and the README attributes it to `reports/round-103/gate/exit-codes.md` with "the fix is a
future-round decision, not silently applied here". Recorded, not repaired — which is the right disposition for a
seat that owns neither file.

### 3.5 `gate/README.md` — dated notes, now in sync: PASS

Two properly formed dated notes, both of which I accept as compliant:

```
$ grep -n "Pin correction note — 2026-10-18\|r103b (2026-10-18\|dated correction, not a rewrite" \
      corpus/knowledge/unreal-mcp/gate/README.md
36:> **r103 (2026-10-18).** The residual queue routed from r102 was closed in the script: …
45:> **r103b (2026-10-18, SEAT-09 HARDENING-AUTHOR).** Two host-dependent defects in the script
207:**Pin correction note — 2026-10-18 (r103, SEAT-05 GATE-PIN-UPDATER).** The `POINTERS` pin in the
230:This is a **dated correction, not a rewrite**: the `87` values are superseded here with the
```

The pin has been re-measured against the current scanner and now matches it exactly:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E 'POINTERS|GATE RESULT'
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
$ grep -n 'POINTERS=101\|NAME_SET=OK\|POINTER_STRINGS' corpus/knowledge/unreal-mcp/gate/README.md | head
120:**Expected:** `CARDS=13 EXPECTED=13 BAD=0`, `NAME_SET=OK NAME_BAD=0`, census …
171:**Expected (re-measured 2026-10-18T18:43Z at lane HEAD `c85a816`, scanner `run_gate.sh` sha256 `577c8b54…` …
175:four. `POINTER_STRINGS` counts the unique pointer *strings* those endpoints came from, …
192:NAME_SET=OK NAME_BAD=0
193:POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
```

All three first-pass drift findings are closed at the final sha: the pin reads `101` and names the scanner sha it
was measured against; `POINTER_STRINGS` is documented, including why endpoints and strings differ (pass A = 47
endpoints from 41 strings); `NAME_SET` is documented and appears in the expected-output block; and CHECK 2's
prose now describes the BLOCKED behaviour instead of the pre-A4 text, with an explicit **"Exit codes"** section
declaring `0`/`1`/`2`.

**Superseded, disclosed.** At the first-pass freeze (README sha `27f7d809…`) I recorded this file as
**FAIL (drift)**: the pin read `91` against an actual `98`, `POINTER_STRINGS` and `NAME_SET` were undocumented,
and CHECK 2's text described a string the gate no longer emitted. That finding was **accurate at that sha** — I
verified each of the three items directly — and the owner fixed all three before the re-verification pass. The
verdict is upgraded to **PASS**; the first-pass text is preserved here so the sequence is auditable rather than
silently overwritten.

Also worth recording, because it bears on how much weight the first pass deserves: the README's `r103b` note
documents two genuine gate bugs found while running the A4 controls — a hardcoded `/tmp/advgate/.h1` scratch path
that made a **clean** tree print `FAIL per-seat manifest sweep` and exit 1 on any host without that directory, and
the `REPO` name collision that made the natural way to exercise A4 (`REPO=<url> run_gate.sh`) silently repoint
sweep B and emit ~26 spurious `MISSING-PATH-REL`. The second is the same trap my own harness fell into (§1.1).
Both are now fixed in the script.

---

## 4. C3 — dead-root ruling and repair

### 4.1 The scope ruling was re-derived, and the premise correction stands

SEAT-30's `reports/round-103/b2/adversary.md` §1 refutes the r101 premise that `.shokunin/game-dev-3d/` never
existed, and bounds the repair-eligible class to class-B command blocks in reproduction READMEs. I did not
re-run the parent-repo `git ls-tree` archaeology (it is outside this seat's scope and read-only against another
repo); I record it as *reported, not re-derived by me*, and note that it is the load-bearing premise for treating
these as path-conformance fixes rather than history rewrites.

### 4.2 The three repairs: mechanically correct, but declared only outside the files

All three landed and all three pass the fold-spec's acceptance:

```
$ for f in corpus/artifacts/glb-r12/README.md corpus/artifacts/unity-r19/README.md corpus/fixtures/three/README.md; do
    printf '%s -> %s\n' "$f" "$(grep -c 'shokunin/game-dev-3d' "$f")"; done
corpus/artifacts/glb-r12/README.md -> 0
corpus/artifacts/unity-r19/README.md -> 0
corpus/fixtures/three/README.md -> 0

$ python3 corpus/artifacts/glb-r12/run_import.py >/dev/null 2>&1; echo "glb exit=$?"
glb exit=0
$ uv run --no-project --with pyyaml python corpus/artifacts/unity-r19/verify_scene.py >/dev/null 2>&1; echo "unity exit=$?"
unity exit=0
$ node corpus/fixtures/three/run_cases.mjs >/dev/null 2>&1; echo "three exit=$?"
three exit=0
```

Diffs are command-lines-only, exactly as a mechanical path fix should be:

```
$ git diff --numstat
3	3	corpus/artifacts/glb-r12/README.md
2	2	corpus/artifacts/unity-r19/README.md
17	17	corpus/fixtures/three/README.md
```

**Discipline verdict: PASS, with a caveat the folding seat must carry.** None of the three files carries an
in-file note:

```
$ grep -c 'orrection note\|dated correction' corpus/artifacts/glb-r12/README.md \
    corpus/artifacts/unity-r19/README.md corpus/fixtures/three/README.md
corpus/artifacts/glb-r12/README.md:0
corpus/artifacts/unity-r19/README.md:0
corpus/fixtures/three/README.md:0
```

This is *defensible* — a path-conformance fix changes no factual or historical claim, so under the r22 precedent
(`reports/round-102/repairs/F1a-r22-readme.md`: *"mechanical command/path conformance fix, applied in place (not a
historical factual claim, so no dated correction note is required)"*) no note is owed. The declarations do exist
and are now complete — `reports/round-103/b2/{ruling,repair-glb,repair-three,repair-unity,verify-glb,verify-three,verify-unity}.md`.
**But nothing in the corpus itself records that these command blocks were re-rooted.** A reader of
`glb-r12/README.md` in six months sees a clean file and no hint that it once carried a different root — which is
precisely the state that made the r22 lesson's re-root invisible until it was audited. The r22 case *did* end up
carrying a note. I flag the asymmetry; whether it is acceptable is the adjudicator's call, not this seat's.

### 4.3 The four-command BEFORE/AFTER pair, re-run by me

```
$ python3 .shokunin/game-dev-3d/corpus/artifacts/glb-r12/run_import.py            → glb exit=2
$ uv run … python .shokunin/game-dev-3d/corpus/artifacts/unity-r19/verify_scene.py → unity exit=2
$ node .shokunin/game-dev-3d/corpus/fixtures/three/run_cases.mjs                  → three exit=1
```

matching the fold-spec's recorded `exit=2 / exit=2 / exit=1` exactly. `corpus/README.md` still carries no
convention note (`grep -c 'shokunin/game-dev-3d' corpus/README.md` → `0`), so fold-spec B2's *ruling* half —
"one of R4's options is chosen and recorded in `LOG.md`" — is **not** satisfied by this round's repairs. The
mechanical half is done; the systemic half is still open.

---

## 5. C3's battery investigation — the row is a **segfault**, not host contention

The brief asks for investigation (not repair) of `phys3d_joints_free_ops`, which failed the r102 idle run
(`corpus/live/runs/20261018T181301123479Z/verdicts.json`, 336/350). Re-derived:

```
$ python3 -c "import json,collections; d=json.load(open('corpus/live/runs/20261018T181301123479Z/verdicts.json'));
  print(collections.Counter(x['verdict'] for x in d['results']))"
Counter({'PASS': 336, 'FAIL': 14})
$ # the 14: 13 × r94_cannon_* with 'exact stdout marker missing', 1 × phys3d_joints_free_ops TIMEOUT
```

### 5.1 The mechanism

`phys3d_joints_free_ops` drives `phys3d_joints.gd --arm=free_ops`, whose `freeb_ops` cell spawns 19 child
processes across three backends. The DEFAULT-backend child **crashes**:

```
$ grep -n "handle_crash\|signal 11" <run>/scratch/r90bt_free_ops_freeb_ops_gp/child.log
handle_crash: Program crashed with signal 11
$ tail -4 <run>/scratch/r90bt_free_ops_freeb_ops_gp/child.log
GDScript backtrace (most recent call first):
    [0] on_e (<run>/scratch/r90_child.gd:109)
    [1] _physics_process (<run>/scratch/r90_child.gd:22)
-- END OF GDSCRIPT BACKTRACE --
timeout: the monitored command dumped core
```

It dies at `r90_child.gd:109` (`PhysicsServer3D.joint_clear(joint)`), after an earlier non-fatal
`ERROR: Parameter "body" is null. … at: body_remove_collision_exception` from line 104
(`joint_disable_collisions_between_bodies`). The crash is mid-case, so the remaining markers never print:

```
$ for d in <run>/scratch/r90bt_free_ops_*; do printf '%-46s DONE=%s\n' "$d" "$(grep -c 'M DONE' $d/child.log)"; done
r90bt_free_ops_freeb_ops_gp    DONE=0      ← the only cell that never completes
r90bt_free_ops_freeb_ops_jolt  DONE=1
r90bt_free_ops_freeb_ops_dummy DONE=1
… (16 others)                  DONE=1
```

The parent then blocks waiting for the `freeb_world` phase that the dead child was supposed to reach, and burns
its full budget: `elapsed_seconds: 20.008` against `case_timeout_seconds: 20` → `TIMEOUT after 20 seconds`.

### 5.2 It is deterministic, not load-dependent

```
$ for r in 20261018T175115311872Z 20261018T175149765516Z … 20261018T183438035892Z; do
    printf '%s signal11=%s\n' "$r" "$(grep -c 'signal 11' corpus/live/runs/$r/scratch/r90bt_free_ops_freeb_ops_gp/child.log)"; done
14 receipts checked → signal11=1 on all 14
```

**14 of 14**, including seven receipts from the *isolated* single-case runs (`"only": "phys3d_joints_free_ops"`)
that were run precisely to remove load as a variable, and including the r102-era receipts.

### 5.3 This falsifies a standing r102 claim

`reports/round-102/r102-verification-protocol.md:572` and `reports/round-102/lesson-verify.md:396,411` record
this row as **host contention** — *"Load-dependent: it passes on an unloaded host and fails under the
concurrent-seat load of a round close"* and *"the failure is host contention, not a fixture defect, and it would
not reproduce on an unloaded machine."* The isolated single-case runs reproduce it under no concurrent load.
The recorded diagnosis is **wrong**, and it is still standing in `reports/round-102/`, which is byte-pinned and
read-only this round.

`reports/round-103/r103-distiller.md` §N3 reaches the *right class* independently ("a TIMEOUT … it is not marker
drift; it is a hang") and correctly separates it from the 13 `r94_cannon_*` marker-drift rows — but stops at
"hang" and does not identify the crash. The two findings are compatible and complementary: N3 fixed the
classification, this seat supplies the mechanism.

**Carry-forward for r104:** the r102 "load-dependent" wording must be superseded by a **dated correction note**
in whichever r104 artifact restates it (the r102 files themselves cannot be edited). A note is owed; a silent
re-description would be the exact violation this seat is auditing for.

---

## 6. Two cross-cutting findings for the folding seat

**(a) The subtree is no longer checkable in isolation — sweep B reaches outside it.** Sweep B counts
backtick-wrapped repo-relative paths and resolves `corpus/…` / `reports/…` against `$REPO_ROOT`. Five round-103
pointers now live inside the subtree and point at worktree-only files. Consequence, measured against the **final**
sha `577c8b54…` on a HEAD-only tree with the live subtree copied in:

```
$ git archive HEAD | tar -x -C <scratch>            # HEAD-only: no reports/round-103 at all
$ test -e <scratch>/reports/round-103 && echo PRESENT || echo ABSENT
ABSENT
$ rm -rf <scratch>/corpus/knowledge/unreal-mcp && cp -r corpus/knowledge/unreal-mcp <scratch>/corpus/knowledge/
$ bash <scratch>/corpus/knowledge/unreal-mcp/gate/run_gate.sh | grep -E 'MISSING|UNRESOLVED|GATE RESULT'
MISSING-PATH-REL reports/round-103/gate/exit-codes.md
MISSING-PATH-REL reports/round-103/gate/hardening.md
MISSING-PATH-REL reports/round-103/note/author.md
MISSING-PATH-REL reports/round-103/note/gate-pin.md
MISSING-PATH-REL reports/round-103/note/urls.md
POINTERS=101 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=5
GATE RESULT: FAIL (checks failed: 1)      → rc=1
```

The same subtree on the live worktree prints `UNRESOLVED=0` / `PASS` / rc=0. So the subtree's own gate verdict now
depends on files **outside** the byte-pinned subtree. Copied to a bare directory with no sibling `corpus/` or
`reports/` at all, it reports 26 `MISSING-PATH-REL` lines and fails outright.

**Superseding my own first measurement, twice.** My first reading of this check reported the HEAD-only tree as
`POINTERS=88 … UNRESOLVED=0 → FAIL` — a count-only mismatch with no missing path. That was wrong: the scratch tree
had been built by `cp -r` over an *already extracted* HEAD archive, so a stale HEAD-era `adaptation-kimi.md` was
still in place. My second reading (at `0c1ca3e1…`) reported 3 dangling pointers; the correct final figure is
**5**, because the C2 seats' own hardening reports added two more citations from inside the subtree. Both earlier
figures are withdrawn; the measurement above is the one to use.

This is a consequence of the r103 edits, not of any C1 or C2 error — every citation is correct and every cited
file exists in the worktree. But the subtree's independence from the rest of the tree is a real property that has
changed, and it should be ruled on before the fold.

**(b) A transient write into the protected `corpus/fixtures/` tree.** At 15:35:23 a sibling seat's battery run
created **21 directories / 42 files** under `corpus/fixtures/` (`r90bt_free_ops_*`), none gitignored and all
visible to `git status`:

```
$ git status --porcelain --untracked-files=all -- corpus/fixtures | grep -c '^??'
42
```

They were gone by 18:37 (`grep -c` → 0), so this was a scratch-litter incident, not a persistent defect — and the
seats-ledger's "all protected paths byte-identical to HEAD" claim is about *tracked bytes* and was not wrong.
Flagged only so the r104 scratch convention is explicit: battery runs must not write under `corpus/fixtures/`.

---

## 7. Limits of this audit

- **The gate changed under me — twice over.** Ten rewrites of `run_gate.sh` and two of `gate/README.md` inside the
  audit window. Every result names its sha. The first pass froze at `0c1ca3e1…`; the verdicts in §3 come from a
  re-verification pass against `577c8b54…`. **Three of my own intermediate results were withdrawn and are marked
  as such in place** rather than deleted: an A2 failure at `55a76cf8…` (superseded by the owner), an A4 "PARTIAL"
  (my harness, §3.4), and two figures for the isolation check (§6a). A reader who wants the audit to be
  reproducible should re-run it against `577c8b54…`, not against any earlier sha quoted here.
- **My first-pass harness was wrong, and it produced a false finding.** Scratch trees built by `cp -r` into an
  empty directory give sweep B no repo root, so every run is red regardless of the mutation. That artefact is
  what made A4 look partially implemented. §1.1 documents the error and the corrected construction; the clean
  control must be green before any mutation result in §3 counts.
- **`/tmp` hit its quota mid-audit** (16 G tmpfs, ~13 G used by concurrent seats' Kimi strings dumps). One
  scratch batch failed with `Disk quota exceeded` and produced no output; it was rebuilt under
  `/home/vgpnk/.cache/s29` and re-run. The failed batch contributed nothing to the findings.
- **Not re-derived by this seat:** SEAT-30's parent-repo `git ls-tree` archaeology (`reports/round-103/b2/adversary.md` §1),
  which is the premise for the "path-conformance, not history rewrite" classification. I record it as reported.
- **The battery-row mechanism is read from logs, not re-executed.** I established that the `freeb_ops` DEFAULT
  child segfaults by reading the 14 existing receipts' `child.log` files and their marker structure. I did not
  re-run the battery to reproduce the crash live, and I did not attempt to fix it — the brief asked for
  investigation only.
- **No Unreal runtime claim** is made or implied anywhere above. Unreal Editor is not installed; live-MCP
  behaviour is unproven by construction. Nothing here is evidence of engine behaviour.
