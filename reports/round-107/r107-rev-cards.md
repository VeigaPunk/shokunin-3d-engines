# r107-rev-cards — REV-CARDS seat (round 107, 3D side-round)

**KEY=REV-CARDS.** Verify the round's **2 refreshed executability cards** against fresh bytes.
Shard `reports/round-107/r107-rev-cards.md`. Scratch `/var/tmp/r107-rev-cards/`. Draft only —
orchestrator lands. No writes into `corpus/knowledge/unreal-mcp/`.

## Plan header (5 lines)

1. Locate the 2 refreshed cards (CARDS-LEAD / CARDS-CRITIC output) — or, if no card draft exists,
   pin the 2 load-bearing cards from the round's own evidence and say so.
2. Recompute every claim from fresh bytes across **3 independent transports** — git object store,
   raw filesystem, and a network fetch — and report agreement per transport.
3. Sweep every cited pointer (path + line range) and every quoted string in both cards.
4. Run the close-out gate on the unmutated tree (baseline PASS) and on planted mutations
   (negative controls) to test whether the gate actually certifies these cards.
5. Label every measurement [O]/[I]/[?]; UNPROVEN stays UNPROVEN; keep under 400 lines.

**Status: COMPLETE.** Axes: A1 independence (values re-derived, not copied from peers) · A2
coverage (both cards, all pointers/quotes/counts) · A3 falsifiability (each verdict names its
falsifier) · A4 non-harm (writes only to `reports/round-107/` + `/var/tmp/r107-rev-cards/`).

## 0. Which cards are "the 2 refreshed cards" — and a finding

**[O] No card draft exists in the round.** Both card seats are plan-header only:
```
$ wc -l reports/round-107/r107-cards.md reports/round-107/r107-cards-crit.md
  12 reports/round-107/r107-cards.md        # CARDS-LEAD  — header only
  32 reports/round-107/r107-cards-crit.md   # CARDS-CRITIC — header only
$ grep -rn "refreshed card" reports/round-107/ reports/round-106/
reports/round-107/r107-cards-crit.md:3:KEY=CARDS-CRITIC. Adversarial seat: attack the refreshed executability cards.
$ git log --oneline -- corpus/knowledge/unreal-mcp/executability/ | head -2
366bb02 r101: vendor EpicGames unreal-engine-skills plugin @ a6aa73ad + 13-card executability lattice ...
$ for f in corpus/knowledge/unreal-mcp/executability/*.md; do git log -1 --format=%h -- "$f"; done | sort -u
366bb02
```
**[O] And no card moved on disk** — all 13 last changed in the r101 landing commit. So "refreshed"
describes *re-verification*, not rewritten bytes. I pinned the **2 cards carrying the round's
card-level risk**, selected from the round's own evidence:

| # | card | why load-bearing | selector |
|---|---|---|---|
| 1 | `executability/actors-scene.md` | the **only** `unproven-runtime` card; the gate census `12/1/0` hinges on it | `run_gate.sh:79 EXPECTED_UNPROVEN=1`; `round-106/next-iteration-carry.md:36` |
| 2 | `executability/testing-automation.md` | the **only** card with a *label-migration* clause — falsifiable on this host | `grep -ln 're-verif\|re-vendor\|fresh pin' executability/*.md` |

**[?] Ambiguity for the orchestrator:** the brief says "2 refreshed cards" without naming them and
no shard names them. If CARDS-LEAD lands a different pair, §1–§4's methodology transfers unchanged.

## 1. Card identity across 3 transports

Cards are lane artifacts, so the network cannot serve them; the three transports are three
*distinct read paths*, not three *distinct sources*. That limit is labelled, not hidden. T1a = git
index/object store (`git rev-parse HEAD:<p>`; `git ls-files -s -- <p>`); T1b = git object read path
(`git cat-file -p $(git rev-parse HEAD:<p>) | sha256sum`); T2 = raw filesystem read (`sha256sum <p>`;
`stat -c%s <p>`; `wc -l < <p>`).

```
$ for f in actors-scene testing-automation; do p="corpus/knowledge/unreal-mcp/executability/$f.md"
    echo "$p blob=$(git rev-parse HEAD:$p) worktree_sha1=$(git hash-object $p) sha256=$(sha256sum $p|cut -c1-64) bytes=$(stat -c%s $p) lines=$(wc -l < $p)"; done
actors-scene.md       blob=90002c9ac335de7417af09e66e9ea086feba2914 worktree_sha1=90002c9ac335de7417af09e66e9ea086feba2914 sha256=3bba50abff45da0cb3b8d8fe2e909692adda5600bf4c6e7871ceaec4180bf9ff bytes=28363 lines=372
testing-automation.md blob=4eaf748cd5d323f945a8a67bde3c1d1d54932d08 worktree_sha1=4eaf748cd5d323f945a8a67bde3c1d1d54932d08 sha256=0a0c85f5f896a1388cff01a8966c2ae375a0b2eba0184c59fc8b1c51014631aa bytes=18150 lines=359
$ for f in actors-scene testing-automation; do p=...; blob=$(git rev-parse HEAD:$p)
    a=$(git cat-file -p "$blob" | sha256sum | cut -d' ' -f1); b=$(sha256sum "$p" | cut -d' ' -f1)
    echo "$f gitcatfile=$a fsread=$b $([ "$a" = "$b" ] && echo AGREE || echo DISAGREE)"; done
actors-scene       gitcatfile=3bba50ab...bf9ff fsread=3bba50ab...bf9ff AGREE
testing-automation gitcatfile=0a0c85f5...31aa  fsread=0a0c85f5...31aa  AGREE
$ git diff --stat HEAD -- corpus/knowledge/unreal-mcp/executability/ ; echo diff_rc=$?    → diff_rc=0
```

**Verdict (card bytes): PROVEN-WITH-EVIDENCE [O].** T1a/T1b/T2 agree exactly; worktree is
byte-identical to `HEAD`. **Not proven:** that these are the *right* bytes — a peer who landed and
committed a wrong card would pass this leg. No independent second source exists for a lane artifact.

## 2. The upstream the cards cite — genuine 3-transport byte-identity

Every card claim resolves into these 12 files, so this is the leg that can be made truly independent.

```
$ git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
a6aa73ada02a9fb1f5415bec491f9942c519b297	refs/heads/main          rc=0
$ curl -sSL -o t.tar.gz -w 'http=%{http_code} bytes=%{size_download}\n' \
   "https://codeload.github.com/.../tar.gz/a6aa73ada02a9fb1f5415bec491f9942c519b297"
http=200 bytes=22990
$ sha256sum t.tar.gz
d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf  t.tar.gz
$ find x -type f | wc -l   → 12
$ gh api repos/.../git/trees/a6aa73ada02a9fb1f5415bec491f9942c519b297?recursive=1 --jq ...
a6aa73ada02a9fb1f5415bec491f9942c519b297 ; 100644 ba4e660a4b05… .claude-plugin/plugin.json ; … (12 blobs, mode 100644)
```
Transports compared per file: T1 = vendored `corpus/knowledge/unreal-mcp/upstream/` (sha256),
T3a = codeload tarball @ pin, no git protocol (sha256), T3b = GitHub REST `git/trees`+`contents`
(git blob sha1).

```
T1 vs T3a, all 12 tracked paths — every row byte-identical (sha256 prefixes):
5aa984848f0fd48c plugin.json  0fad2f57a9fac18a .gitignore  653d372559bee26d CODEOWNERS
5b337be051359edc LICENSE      483693ad0e14d027 README.md   259124f0631b7d4b hooks/hooks.json
d3f1c871cd4edd52 hooks/unreal-context.sh  e9d050087f36de51 create-toolset/SKILL.md
7ef8b991a82f591c unreal-mcp/SKILL.md  dbed002b4a46ab10 references/operations.md
bd16206ea142dc9c references/setup.md  7a0af781c458c7d1 unreal-skill/SKILL.md   ALL_EQUAL True n= 12
```
T3b spot-check via a third API surface (`contents`): `README.md` → `44c8dd3ef9ac15d11de88973ab558b4c2ff57044`,
`skills/unreal-mcp/SKILL.md` → `9cd2cc2656d05a738f5814fb2945cc48daff66fc`,
`references/setup.md` → `49a921a9ab818a8912e5d4781fa8d6869dd27dfa` — each equals the vendored
`git ls-files -s` blob id. **[O]**
Also reproduced unmutated: `sha256sum -c .manifest.d/audit-reference.sha256` → 12/12 `OK`, `rc=0`.

**Verdict (upstream bytes): PROVEN-WITH-EVIDENCE [O].** 12/12 byte-identical across git clone,
codeload tarball, and REST blobs — transports sharing no local state. The pin is unchanged from
r101, so this re-establishes the *same* commit; the round's value is the independent re-derivation.

## 3. Card 1 — `actors-scene.md` (28363 B, 372 lines, sha256 `3bba50ab…bf9ff`)

### 3.1 Label and census

```
$ head -40 actors-scene.md | grep -nE '<gate LABEL_RE>'          → 5:**Label:** `unproven-runtime`
$ <census parser, r106 carry's five declaration shapes, all 13 cards>
COUNTS {'verified-here': 0, 'static-only': 12, 'unproven-runtime': 1} total 13
```
**[O]** Declared `unproven-runtime` at line 5; live census `12/1/0` equals the gate constants
`EXPECTED_STATIC=12 EXPECTED_UNPROVEN=1 EXPECTED_VERIFIED=0` (`run_gate.sh:78-80`).

### 3.2 Pointer sweep — 56 distinct pointers, 70 citations

```
$ python3 ptr.py corpus/knowledge/unreal-mcp/executability/actors-scene.md
card=actors-scene.md distinct_pointers=56 total_citations=70
  .claude-plugin/plugin.json:4 -> IN-RANGE x1
  README.md:3 / :17 / :18 / :23-28 / :65 / :66 / :70-72 / :78 / :82 / :100(x5) / :106 / :111 -> IN-RANGE each
  SKILL.md:3(x4) / :8 / :22 ; skills/unreal-mcp/SKILL.md:16 / :20 / :22 / :24 / :30-:34 -> IN-RANGE each
  corpus/knowledge/unreal-mcp/README.md:41(x2) / :12-59 / :23-24 / :31-48 / :204-240 / :209-211 -> IN-RANGE each
  create-toolset/SKILL.md:3 / :54 / :211 ; skills/create-toolset/SKILL.md:3(x2) / :20 / :26 / :45 / :211 / :234
  references/operations.md:13 / :18-21 / :34 / :48 / :49(x2) / :51 ; references/setup.md:12-31 / :35-46 / :57-79 / :85 / :131
  hooks/unreal-context.sh:14 ; plugin.json:4 ; unreal-skill/SKILL.md:3
unresolved=0: []
```
**[O] 0 unresolved, 0 out-of-range.** The same sweep against the **network** copy of `upstream/`
returns the identical result (`unresolved=0`), so the pointers are checkable against the wire, not
only against the vendor tree.

### 3.3 Quoted-string sweep — 21 quoted claims

A naive normalizer flagged 6 "not found"; all 6 are the card's own honest `...` elisions, not
misquotes. Each verified against network bytes:

| claim | card text | fresh bytes | verdict |
|---|---|---|---|
| F1 | `"**Actors and Scene** - spawn, transform, inspect, and delete actors; manage components and outliner folders"` | `README.md:100` identical, incl. four verb-groups | **[O] exact** |
| F2 | `"Hundreds of tools ... across 30+ toolsets: actors, blueprints, materials, ..."` | `README.md:3` — fragments verbatim; elisions are the card's | **[O] exact** |
| F4 | `"hundreds of tools across 30+ toolsets (actors, ...) registered through Unreal's `ToolsetRegistry`"` | `SKILL.md:8` verbatim | **[O] exact** |
| F19/F20/F21 | `"**Save first, then save again.** ..."`, `"**Control concurrent calls.** ..."`, `"**Always check the result.** ..."` | `SKILL.md:30/32/33` — fragments verbatim | **[O] exact** |
| F26 | `"The editor must still run for live tool calls."` | `references/setup.md:85` verbatim | **[O] exact** |

### 3.4 Named-entity claims, the executable receipt, and one count defect

```
$ grep -rn "ActorTools" <network upstream>/ ; echo rc=$?   → rc=1   [O] zero hits (F5 sweep claim)
$ grep -rn "LevelTools" <network upstream>/    → 1 hit, create-toolset/SKILL.md:3 (the F11 list)  [O]
$ grep -rn "bIsLocked" <network upstream>/     → 1 hit, unreal-mcp/SKILL.md:3 (`bIsLocked` on `BP_DoorActor`)  [O]
$ grep -rn "FToolsetTransformConverter" <network upstream>/ → 1 hit, create-toolset/SKILL.md:211  [O]
$ sed -n '100,112p' README.md | grep -c '^- \*\*'   → 13   [O] 13 domains, as claimed
$ command -v shellcheck && shellcheck corpus/.../upstream/hooks/unreal-context.sh ; echo rc=$?
/usr/bin/shellcheck ; rc=0                                        [O] clean, as the card claims
$ cd /var/tmp/r107-rev-cards/fake/Source/MyGame && bash .../upstream/hooks/unreal-context.sh
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This working directory is an Unreal Engine project. ..."}}
$ sed -n '173p' actors-scene.md | grep -o '`[A-Za-z0-9_./-]*:[0-9]*`' | wc -l    → 5
$ grep -rn "does not prove that Unreal is reachable\|does not test current reachability\|..." <network upstream>/ | wc -l
5
```
**[O]** F11 ("only occurrence"), F12–F14 and the 13-domain census reproduce; the hook executes and
emits `SessionStart` — the card's asymmetry claim (harness half exercisable, tool half not) is
accurate as written.

**[O] FINDING (low impact): the card's F27 says "stated four times" but cites five pointers**
(`README.md:65`, `:78`, `SKILL.md:24`, `operations.md:34`, `setup.md:131`). Five distinct warning
lines exist, so the *pointers* are right and the *count word* is wrong. Every cited line does carry
a reachability-skepticism warning. The claim survives; the numeral should read "five".

### 3.5 Card 1 verdict

**PROVEN-WITH-EVIDENCE**, one numeral defect: **56/56 pointers resolve in-range across two
transports; 21/21 quoted claims match; label and census match the gate constants; the single
executable receipt reproduces.** Falsifiers: a pointer failing to resolve (`ptr.py` →
non-zero `unresolved`), a quote differing (`quotes.py`), or a label declaration `LABEL_RE` misses.

## 4. Card 2 — `testing-automation.md` (18150 B, 359 lines, sha256 `0a0c85f5…31aa`)

### 4.1 Label, and the migration clause that makes this card falsifiable here

```
$ head -40 testing-automation.md | grep -nE '<gate LABEL_RE>'   → 5:**Label:** `static-only`
```
**[O]** Declared `static-only`, line 5 — matches `EXPECTED_STATIC=12`.

The migration clause is the card's most testable sentence: *"this card moves `static-only` →
`unproven-runtime` the moment an `UnrealEditor-Cmd` binary exists on the host ... and →
`verified-here` only when step 3's exit-code contract is captured."*

**[O] Falsifier run:** `command -v UnrealEditor-Cmd` → rc 1; `command -v UnrealEditor` → rc 1;
`ls /opt` → `1Password claude-code containerd intel packages spotify`. No editor binary exists →
the migration trigger has **not** fired → `static-only` is the correct label **today**. The card
states the trigger and does not claim it fired.
**[?]** Only *partly* falsifiable here: I can prove the trigger is absent, but not that it would
flip the label — that needs an editor. `verified-here` stays UNPROVEN on this host, as the card says.

### 4.2 Pointer sweep — 9 distinct pointers, 12 citations

```
$ python3 ptr.py corpus/knowledge/unreal-mcp/executability/testing-automation.md
  .claude-plugin/plugin.json:3 -> IN-RANGE ; README.md:25 / :76 / :110 -> IN-RANGE
  references/setup.md:31 / :66 -> IN-RANGE
  setup.md:31                  -> NO-FILE among [...upstream/setup.md, ...unreal-mcp/setup.md]
  skills/create-toolset/SKILL.md:242 -> IN-RANGE ; skills/unreal-skill/SKILL.md:85 -> IN-RANGE
unresolved=1: ['setup.md:31']
```**[O] FINDING (cosmetic): `setup.md:31` at line 172 is a bare shorthand the card never expands.**
Unlike `actors-scene.md`, this card has no "Pointer convention" table. The *same source* is cited
correctly as `references/setup.md:31` at line 102 — so the fact is right and only the form is
inconsistent; a reader resolving `setup.md` literally lands on a non-existent path. The line range
is correct: `sed -n '31p' references/setup.md` is the `AllToolsets` sentence the claim quotes.
**[O] 8/9 pointers resolve; the ninth is a form defect, not a factual one.**

### 4.3 The five en-dash range pointers — checked, because the gate cannot (§5.2)

```
L30  README.md:100–112 / L64 skills/create-toolset/SKILL.md:388–395 / L79 :232–251
L161 create-toolset/SKILL.md:388–395 / L181 :399–404        → all IN-RANGE
$ sed -n '388,395p' create-toolset/SKILL.md
Run tests via MCP: 1. Load `AutomationTestToolset` and call `DiscoverTests`. ... 2. Call `ListTests` filtered to
your toolset name ... 3. Call `RunTests` with the full test paths. 4. Poll `GetTestStatus`, then call
`GetTestResults` ... ; When iterating on Python tests, call `DiscoverTests` with `force_rediscover=true` ...
```
**[O] 5/5 in-range**, and the card's `[O]` claim of "six tool names + call order" at `:388–395` is
**[O] exact**: `AutomationTestToolset`, `DiscoverTests`, `ListTests`, `RunTests`, `GetTestStatus`,
`GetTestResults`.

### 4.4 The census claim — the card's strongest quantitative assertion

Card: *"Total across all 12 vendored files: **10 mentions, all in one file**
(`skills/create-toolset/SKILL.md`), plus a single catalog line in `README.md:110`."*

```
$ grep -ro "AutomationTestToolset\|UnrealEditor-Cmd\|DiscoverTests\|RunTests\|ListTests\|GetTestStatus\|GetTestResults" <network upstream>/ | sort | uniq -c | sort -rn
      2 create-toolset/SKILL.md:UnrealEditor-Cmd      1 create-toolset/SKILL.md:ListTests
      2 create-toolset/SKILL.md:RunTests              1 create-toolset/SKILL.md:GetTestStatus
      2 create-toolset/SKILL.md:DiscoverTests         1 create-toolset/SKILL.md:GetTestResults
      1 create-toolset/SKILL.md:AutomationTestToolset ; $ ... | wc -l    → 10
```
**[O] EXACT MATCH** — all seven tokens, all counts, all in one file. The card's grep receipt
reproduces line-for-line. Supporting sub-claims, all **[O]**:
```
$ grep -n "automation\|testing\|Test" skills/unreal-mcp/SKILL.md   → 2 lines (L8 list item, L55 create-toolset
   description), neither about Testing — as the card says
$ grep -c "Test" references/operations.md references/setup.md       → 0 ; 0  → "both grep to zero" confirmed
$ cat .claude-plugin/plugin.json                                    → "version": "3.1.1"  [O] as cited
```

### 4.5 Card 2 verdict

**PROVEN-WITH-EVIDENCE**, one cosmetic citation defect: **8/9 pointers resolve (the 9th is an
unexpanded shorthand); 5/5 en-dash ranges in-range; the 10-mention census reproduces exactly; the
label and its migration trigger are correct for this host.** The migration clause is honestly
scoped — trigger absent, no promotion claimed.

## 5. Does the gate certify these cards? Baseline + 5 negative controls

Ran the round's own gate draft (`reports/round-107/mutations/gate-draft.sh`, copied in as
`gate/run_gate.sh` in a staged throwaway tree; `GATE_WORKDIR` set to a roomy path per the r106
carry's `/tmp` rule).

### 5.1 Baseline on the unmutated tree — GREEN

```
$ GATE_WORKDIR=/var/tmp/r107-rev-cards/gatework bash corpus/knowledge/unreal-mcp/gate/run_gate.sh
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0 ; STEP=PASS                              # CHECK 1
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297 ; BLOB_DIFFS=0 ; STEP=PASS    # CHECK 2
OK unproven-runtime actors-scene.md line 5 / OK static-only testing-automation.md line 5   # CHECK 3
CARDS=13 EXPECTED=13 BAD=0 ; CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0 ; STEP=PASS
POINTERS=103 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0 ; STEP=PASS  # CHECK 4
GATE RESULT: PASS (checks failed: 0)
```
**[O]** Gate passes; CHECK 3 independently confirms both cards' labels and the census. Exit 0.

### 5.2 Negative controls — 3 caught, 2 missed (a real hole)

| # | mutation (one card, one variant) | gate output | verdict |
|---|---|---|---|
| NC1 | `actors-scene.md:5` `unproven-runtime` → `verified-here` | `CENSUS … verified-here=1 EXPECTED=12/1/0` ; `STEP=FAIL` ; `GATE RESULT: FAIL (checks failed: 1)` | **DETECTED** |
| NC2 | plant `upstream/README.md:9998` in card 1 | `LINE-OOR … (max 112)` ; `UNRESOLVED=1` ; `FAIL` | **DETECTED** |
| NC3 | plant `upstream/skills/unreal-mcp/references/setup.md:9998` | `LINE-OOR … (max 133)` ; `UNRESOLVED=1` ; `FAIL` | **DETECTED** |
| NC4 | plant the **shorthand** form `README.md:9999` in card 1 (the card's dominant form) | `POINTERS=103 … UNRESOLVED=0` ; `GATE RESULT: PASS` | **MISSED** |
| NC5 | plant the **en-dash** form `create-toolset/SKILL.md:3888–3995` in card 2 | `POINTERS=103 … UNRESOLVED=0` ; `GATE RESULT: PASS` | **MISSED** |

**Mechanism [O], from `run_gate.sh` CHECK 4 pass A:**
```sh
done < <(grep -ohE "upstream/[^\`\"|)]+\.[A-Za-z0-9]+:[0-9]+([,-][0-9]+)*" "$f" | sort -u)
```
Pass A range-checks **only `upstream/`-prefixed** line pointers, and its regex admits only ASCII
`-` and `,` separators — not U+2013. Pass B checks *path existence* for backticked
`corpus/…`/`reports/…` tokens but never validates a line number.

**Coverage arithmetic [O]** — distinct pointers, deduped exactly as the gate dedupes:
```
                        gate pass-A (range-checked)   shorthand (NOT range-checked)
actors-scene.md                    0                            63
testing-automation.md              0                            19
all 13 cards, totals              20                           354
```
**[O] 20 of 374 distinct card line-pointers (5.3%) are in the gate's range-check scope.** The two
cards verified here contribute **0 of 82**. A corrupted line number in `actors-scene.md` or
`testing-automation.md` — in the form those cards actually use — **passes the gate green**
(NC4, NC5). That is why an independent reviewer, not the gate, is what certifies §3.2/§4.2.

**Honest scope note [O]:** `gate/README.md` states its own scope as *"Every `upstream/<path>:<line>`
pointer …"* — this is a **documented limitation, not a hidden bug**. The finding is that the gate's
green `UNRESOLVED=0` must not be read as certifying card line numbers, since the cards
predominantly use the out-of-scope shorthand. (An *exact* sentinel — `upstream/README.md:9999` —
is skipped by design: NC shows `SKIPPED_CONTROL_SENTINELS=1`, `PASS`.)

## 6. Cross-seat finding (not my deliverable, but it affects landing)

**`reports/round-107/r107-VENDOR-A.md` §2's `size (B)` column is wrong on all 12 rows.** Claimed
vs actual bytes under `corpus/knowledge/unreal-mcp/upstream/`: plugin.json 178/487 ; .gitignore
19/203 ; CODEOWNERS 42/64 ; LICENSE 11357/1073 ; README.md 7085/8398 ; hooks/hooks.json 564/357 ;
hooks/unreal-context.sh 1530/3101 ; create-toolset/SKILL.md 4170/23258 ; unreal-mcp/SKILL.md
12217/7098 ; references/operations.md 15383/6497 ; references/setup.md 17160/6065 ;
unreal-skill/SKILL.md 3317/6955. **[O] 12/12 wrong.** The shard's own structured artifact is
correct — `va-manifest.json` `size_bytes` matches disk on 12/12 and `git_blob_sha1` matches
`git ls-files -s` on 12/12 — so the defect is confined to the markdown table, not the manifest.

**[O] `/var/tmp/r107-va/rawsha1.txt` is also mislabeled:** it holds raw `sha1sum` digests, not git
blob ids (`rawsha1.txt` → `714565c9…` for `plugin.json`; the git blob is `ba4e660a…`; the actual
`sha1sum` is `714565c9…`). 0/12 of its values equal the index blobs it is filed beside — a
naming/attribution error, not a corruption.

**[O]** VENDOR-A's `sha256` column and its 12/12 `hash-object`-vs-index self-check are correct
(reproduced in §2). **Recommendation: do not propagate VENDOR-A's `size (B)` column into the landed
`PROVENANCE.md`.** Peer shards `r107-scribe-report.md:149` and `r107-rev-pin.md` §6 flag the same
defect independently; I reached it from the byte side without reading either.

## 7. Verdicts
| # | claim | verdict | strongest evidence |
|---|---|---|---|
| 1 | both cards' bytes are stable and unmodified | **PROVEN-WITH-EVIDENCE [O]** | T1a/T1b/T2 agree; `git diff HEAD` rc=0 |
| 2 | the 12 cited upstream files are byte-identical to the pin | **PROVEN-WITH-EVIDENCE [O]** | clone + codeload + REST blobs, 12/12; tarball `d091941c…` |
| 3 | `actors-scene.md` pointers resolve | **PROVEN-WITH-EVIDENCE [O]** | 56/56 in-range, two transports, `unresolved=0` |
| 4 | `actors-scene.md` quotes are verbatim | **PROVEN-WITH-EVIDENCE [O]** | 21/21; 6 apparent misses are the card's own `...` elisions |
| 5 | `actors-scene.md` F27 "stated four times" | **REFUTED (numeral only) [O]** | 5 pointers cited, 5 warning lines exist |
| 6 | `actors-scene.md` label + census | **PROVEN-WITH-EVIDENCE [O]** | `unproven-runtime` L5; live census 12/1/0 = gate constants |
| 7 | `actors-scene.md` hook receipt executes | **PROVEN-WITH-EVIDENCE [O]** | `shellcheck` rc=0; hook emits `SessionStart` |
| 8 | `testing-automation.md` pointers resolve | **PROVEN-WITH-EVIDENCE (8/9) [O]** | `setup.md:31` unexpanded shorthand; line range correct |
| 9 | `testing-automation.md` 10-mention census | **PROVEN-WITH-EVIDENCE [O]** | exact reproduction, 7 tokens, all in one file |
| 10 | `testing-automation.md` en-dash ranges | **PROVEN-WITH-EVIDENCE [O]** | 5/5 in-range; gate cannot check these (§5.2) |
| 11 | `testing-automation.md` label + migration trigger | **PROVEN-WITH-EVIDENCE [O]** | `static-only` L5; no editor binary → trigger unfired |
| 12 | a future label promotion | **UNPROVEN-WITH-ATTEMPT-LOG [?]** | falsifier run: `command -v UnrealEditor-Cmd` → rc 1 |
| 13 | the close-out gate certifies these cards' line numbers | **REFUTED [O]** | NC4/NC5 pass green; 20/374 pointers in scope |
### UE runtime label
**`unproven-with-attempt-log`.** No Unreal runtime was exercised by this seat and none can be:
`command -v UnrealEditor-Cmd` → rc 1; `command -v UnrealEditor` → rc 1. A sibling's
`docker pull wukakuki/unreal-engine:dev-slim-5.8.3` was mid-flight throughout
(`/var/tmp/ue-pull.log`, pid 596299; `docker images | grep -i unreal` → no match at this read).
Recorded as context only — this seat did not touch, wait on, or depend on it. **No card may be
promoted on the strength of anything in this shard.**

## 8. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin
# 1. card identity, 3 transports
for f in actors-scene testing-automation; do p=corpus/knowledge/unreal-mcp/executability/$f.md
  git rev-parse HEAD:$p; git hash-object $p; sha256sum $p; stat -c%s $p; wc -l < $p; done
git diff --stat HEAD -- corpus/knowledge/unreal-mcp/executability/        # empty
# 2. upstream, 3 transports
git ls-remote https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin main
curl -sSL -o /var/tmp/r107-rev-cards/net/t.tar.gz https://codeload.github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin/tar.gz/a6aa73ada02a9fb1f5415bec491f9942c519b297
sha256sum /var/tmp/r107-rev-cards/net/t.tar.gz   # d091941cc80bff11e3190c20611e6740680fde13daee0d00e9c6e659bd3618cf
gh api repos/EpicGames/unreal-engine-skills-for-claude-code-plugin/git/trees/a6aa73ada02a9fb1f5415bec491f9942c519b297?recursive=1
# 3. pointer sweeps (this seat's checker)
python3 /var/tmp/r107-rev-cards/ptr.py corpus/knowledge/unreal-mcp/executability/{actors-scene,testing-automation}.md
NETUP=/var/tmp/r107-rev-cards/net/x/unreal-engine-skills-for-claude-code-plugin-a6aa73ada02a9fb1f5415bec491f9942c519b297/ \
  python3 /var/tmp/r107-rev-cards/ptr-net.py corpus/knowledge/unreal-mcp/executability/actors-scene.md
# 4. gate baseline + negative controls
cd /var/tmp/r107-rev-cards/gatew/lane && GATE_WORKDIR=/var/tmp/r107-rev-cards/gatework bash corpus/knowledge/unreal-mcp/gate/run_gate.sh   # PASS
#   staged mutants: neg2 (label flip, FAIL) neg3/neg6/neg7 (upstream/ line, FAIL)
#                   neg4 (shorthand line, PASS = hole) neg5 (exact sentinel, PASS by design)
# 5. executable receipt
shellcheck corpus/knowledge/unreal-mcp/upstream/hooks/unreal-context.sh
```

## 9. What this seat did NOT do

- Did not write, stage, or land anything under `corpus/` — all mutation trees live under
  `/var/tmp/r107-rev-cards/`; only this shard was written in the lane repo (`git status` clean
  apart from `?? reports/round-107/`). Did not commit, push, checkout, or reset.
- Did not read any peer shard's values for the claims it verified (only for *selection* of the two
  cards, §0). §6's cross-checks were formed from bytes first, then compared to peer prose.
- Did not run the battery, the 3D fixture battery, or Godot. Did not touch the 2D lane.
- Did not pull, run, or depend on the Unreal docker image, and did not claim any UE runtime.

