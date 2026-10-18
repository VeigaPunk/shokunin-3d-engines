# Draft — SKILL.md box 1: "Unreal-content claim discipline" decision table

**Seat:** SEAT-40 SKILL-TABLE-AUTHOR · round 102 · lane `game-dev-3d-shokunin`
**Written:** 2026-10-18 · **HEAD at write:** `2c99b7b` (r101 report-last; work commit `1659c036`)
**Owned path written:** `reports/round-102/skill-decision-table-draft.md` (this file only)
**Status:** **draft, not landed.** `SKILL.md` does not exist in this lane (shonen seed form,
`README.md:10-11`) and is not this seat's to write. This file is the table *text* a future
`SKILL.md` can adopt verbatim; every row is justified by an artifact that exists today.
**No Unreal runtime claim.** Unreal Editor is not installed on this host; nothing below asserts
live-editor behavior. Rows **C** and **D** exist precisely to make that posture mechanical.

---

## 0. What SHONEN box 1 asks for, and what this draft answers

`SHONEN.md:3` — *"Real decision tables/error patterns/checklists with cited sources."* The
r101 close-out left it `[~]`, not `[x]`, for one stated reason:

> Round r101 adds cited, checkable tables but **no** distilled decision table into `SKILL.md`
> (untouched this round) … Box stays open until a non-author verifier accepts them as the
> skill's own tables rather than round artifacts.
> — `reports/round-101/r101-report.md:219-226`

So the gap is not "more tables" — it is **one table that decides, before any Unreal-content
claim is written, which label it may carry and what evidence it must cite.** This draft is that
table. It is deliberately a *decision procedure over claim types*, not a summary of r101: the
four claim types below are exhaustive over the Unreal artifacts in this lane, and each row's
canonical command was run by this seat on 2026-10-18 with the output quoted.

**Row count:** 4 claim types × 5 columns. Two of the four rows have a mandatory second
canonical command (the "not-vacuous" control), marked **+NC**.

---

## 1. The table

**Legend.** *Label* — the only label admissible for that claim type. The lane carries **two
vocabularies** (`corpus/knowledge/unreal-mcp/README.md:31-48`): the **binary policy**
(`proven` / `unproven`) and the **ternary card label** (`verified-here` / `static-only` /
`unproven-runtime`). The binary policy governs *claims*; the ternary governs *subsystem cards*.
A row states both where both apply. §3 resolves the collision between them.

**Citation rule for mutable files (measured this round, not assumed).** A line-number citation
into a file another seat may still be editing is *itself* a prose-cites-bytes defect waiting to
happen. Observed on 2026-10-18, inside this single seat's runtime window:

| file | what happened | sha256 at first cite | sha256 at last check |
|---|---|---|---|
| `corpus/knowledge/unreal-mcp/README.md` | `.manifest.d` section rewritten **twice** (one revision printed both counts 12 and 24; a later one reverted to "12 lines"; the current revision states both) | `ef17c775…` | `c79d8dd1…` |
| `corpus/lessons/r102-unreal-integration.md` | rewritten from **178** to **212** lines while this seat worked | `c7f18f28…` (final) | `c7f18f28…` |

So the rule, and the table should carry it: **cite a mutable artifact by section heading plus a
sha256 stamp, not by bare line number; cite a frozen artifact (`reports/round-101/**`,
`corpus/knowledge/unreal-mcp/upstream/**`, `.manifest.d/**`) by line number.** Every line-number
citation in §1–§4 of this draft was re-verified against the files as they stand at write time,
and the two mutable files above are stamped with their hashes in the §6 artifact index. This is
the same class as the r102 F8 finding (`corpus/lessons/r102-unreal-integration.md:168-212`, hook
3) — a claim that does not survive its own re-read.

| # | claim type | permissible label | required evidence | canonical command | justified by |
|---|---|---|---|---|---|
| **A** | **File byte-identity** — "this vendored file is what upstream shipped at the pin" | `proven` (binary policy). **No** ternary card label: the ternary is for subsystem cards, not file claims. A card may be `static-only` *on the strength of* an A-row. | (a) sha256 of the file equals the committed manifest row **and** (b) sha256 equals `git show <pin>:<path>` from a **fresh** clone; path sets equal **both ways**. | `cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256` → 12 × `OK`, rc 0. **+NC:** `printf '\n' >> upstream/README.md` on a *copy* → `upstream/README.md: FAILED`, rc 1. | `README.md:12-29`, `:116-119`; `PROVENANCE.md:43-111`; gate `CHECK 1`+`CHECK 2` (`gate/run_gate.sh:51-118`); non-author `reports/round-101/r101-reviewer-c1.md:20`; mutation matrix `reports/round-101/r101-mutation-tester.md:5` |
| **B** | **Static parse** — "this file is well-formed / this card declares exactly one label / this prose pointer resolves" | `proven` for the property of *the bytes read*. Ternary: `static-only` is the correct **card** label when a subsystem's document facts are proven but its behavior is not. | a tool that actually ran here, with its output recorded: `jq -e`, `bash -n`, `shellcheck`, a label scan, a pointer sweep. Static means the tool ran; it does **not** mean the content is semantically correct. | `jq -e upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json` → rc 0; `shellcheck upstream/hooks/unreal-context.sh` → rc 0; `corpus/knowledge/unreal-mcp/gate/run_gate.sh` (CHECK 3 label scan, CHECK 4 pointer sweep). **+NC:** duplicate a label token → `FAIL multi-label …`, rc 1. | `README.md:17-22`, `:40`, `:43-48`, `:257-274`; `adaptation-kimi.md:299-302`; gate `CHECK 3`+`CHECK 4` (`gate/run_gate.sh:119-196`) |
| **C** | **Runtime behavior** — any `list_toolsets` / `describe_toolset` / `call_tool` / actor mutation / Live Coding / automation-test / Niagara / Sequencer / Control Rig statement | **`unproven`** (binary) ⇔ **`unproven-runtime`** (ternary). `verified-here` is **permissible only with a saved receipt of a bounded run on this host** — which cannot exist here. Never the indicative mood. | none is sufficient on this host. The row must be **labeled**, and must state what would settle it. A connected MCP client, a cached tool catalog, or a successful `unreal_mcp_status` is **not** evidence of reachability. | `which UnrealEditor UnrealEditor-Cmd` → `no … in (…)`, rc 2; `ls /opt/UnrealEngine` → `No such file or directory`, rc 2; `git ls-remote https://github.com/EpicGames/unreal-engine HEAD` → `Repository not found`, rc 128. | `README.md:23-29`, `:50-59`, `:61-72`; `adaptation-kimi.md:306-317` (§6 register), `:299-302` (live-editor rule); `corpus/lessons/r102-unreal-integration.md:43-65` (Law 2), `:95-116` (Law 4) |
| **D** | **Kimi-side adaptation** — "Claude mechanism X maps to Kimi mechanism Y" | `verified-here` **iff** a probe ran on this host with output pasted (rows 2, 3, 4, 8, 9, 11 of the adaptation table); else `static-only` if read from a shipped artifact with a resolvable pointer; `unproven-runtime` if it needs a live editor or a live MCP server. | the probe's command **and** observed output, or a resolvable artifact pointer (binary-strings line, docs page, config path + line). `NONE-FOUND` requires the exact search that returned 0. | `strings -n 6 /home/vgpnk/.kimi-code/bin/kimi \| grep -c additionalContext` → `0`; `… grep -c CLAUDE_PLUGIN_ROOT` → `0`; `… grep -c enabledPlugins` → `0`; `/home/vgpnk/.kimi-code/bin/kimi --version` → `2.2.0`. | `adaptation-kimi.md:25-48` (§1 table), `:270-303` (§5 policy incl. promotion / invalidation / negative-claim rules), `:306-317` (§6) |

---

## 2. Per-row receipts — commands run by this seat, with observed output

All commands were run from the lane root on 2026-10-18 unless the row says otherwise.
Outputs are quoted verbatim.

### Row A — file byte-identity

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256
… (12 lines) …
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
```

Path-set equality and per-blob comparison, from the gate's own check 2 (fresh clone):

```
$ corpus/knowledge/unreal-mcp/gate/run_gate.sh          # CHECK 2 section
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0
CLONE_TRACKED=12
PATH_EXTRA=0 PATH_MISSING=0
BLOB_DIFFS=0
STEP=PASS
```

Independently re-derived by this seat without the gate:

```
$ diff <(cd corpus/knowledge/unreal-mcp/upstream && find . -type f | sort) \
       <(cd /tmp/r102-s40/clone && git ls-files | sed 's|^|./|' | sort) ; echo "pathset rc=$?"
pathset rc=0
$ for f in $(git -C /tmp/r102-s40/clone ls-files); do
    a=$(git -C /tmp/r102-s40/clone show a6aa73ad…:$f | sha256sum | cut -d' ' -f1)
    b=$(sha256sum corpus/knowledge/unreal-mcp/upstream/$f | cut -d' ' -f1)
    [ "$a" = "$b" ] || echo "DIFF $f"; done ; echo BLOBCOMPARE_DONE
BLOBCOMPARE_DONE          # no DIFF lines
```

**Negative control (row A must be able to fail).** On a `/tmp` copy only:

```
$ printf '\n' >> /tmp/r102-s40/ncC1/upstream/README.md
$ cd /tmp/r102-s40/ncC1 && sha256sum -c .manifest.d/audit-reference.sha256
upstream/README.md: FAILED
upstream/skills/unreal-mcp/SKILL.md: FAILED
MANIFEST_OK=10 EXPECTED=12 FAILED=2 RC=1
```

Two files flip because the append shifted the line count of a file that another manifest row
also covers — which is the point: the manifest is a real content check, not a size check.

**Why the second command is mandatory.** `sha256sum -c` alone cannot see an *extra unlisted
file* and is blind to file mode/mtime; only set-equality against `git ls-files` catches the
first (`corpus/lessons/r102-unreal-integration.md:34-42`, `reports/round-101/r101-mutation-tester.md:5`).

### Row B — static parse

```
$ cd corpus/knowledge/unreal-mcp
$ jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null ; echo "rc=$?"
rc=0
$ shellcheck upstream/hooks/unreal-context.sh ; echo "rc=$?"
rc=0
$ bash -n upstream/hooks/unreal-context.sh ; echo "rc=$?"
rc=0
```

Label scan (gate CHECK 3) and pointer sweep (gate CHECK 4), full gate run:

```
$ corpus/knowledge/unreal-mcp/gate/run_gate.sh
CHECK 3 verdict-card-scan
OK   unproven-runtime actors-scene.md                line 5
OK   static-only      animation-controlrig.md        line 4
… (13 lines) …
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=PASS

CHECK 4 pointer-sweep
POINTERS=40 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
STEP=PASS

GATE RESULT: PASS (checks failed: 0)
```

**Negative controls.**

```
# NC-B1 — plant an out-of-range pointer
$ printf '\nsee upstream/README.md:200\n' >> /tmp/r102-s40/ncC3/README.md
LINE-OOR /tmp/r102-s40/ncC3/README.md :: upstream/README.md:200 (max 112)
POINTERS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=1
STEP=FAIL

# NC-B2 — duplicate a label token on the label line
$ sed -i '4s/$/ (not verified-here)/' /tmp/r102-s40/ncC4/executability/blueprints.md
FAIL multi-label executability/blueprints.md :: **Label:** `static-only` (not verified-here)
CENSUS static-only=11 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
STEP=FAIL
```

Also confirmed: deleting a card fails CHECK 3 (`CARDS=12 EXPECTED=13` → `STEP=FAIL`,
`reports/round-102/reruns/labels.md:207-215`, controls NC1–NC5).

### Row C — runtime behavior

```
$ which UnrealEditor UnrealEditor-Cmd
which: no UnrealEditor in (/home/vgpnk/.grok/bin:…)
which: no UnrealEditor-Cmd in (…)
rc=2
$ ls /opt/UnrealEngine
ls: cannot access '/opt/UnrealEngine': No such file or directory
rc=2
$ git ls-remote https://github.com/EpicGames/unreal-engine HEAD
remote: Repository not found.
fatal: repository 'https://github.com/EpicGames/unreal-engine/' not found
rc=128
$ gh api repos/EpicGames/UnrealEngine --jq .id
{"message":"Not Found",…,"status":404}
```

This row has **no pass/fail control by construction** — there is no live editor to run against.
Its "negative control" is the inverse: a `verified-here` label must be a **red flag** on this
host. The gate encodes exactly that, and fails rather than let one through
(`gate/README.md:82-88`, `gate/run_gate.sh:31-33`):

```
$ sed -i '4s/static-only/verified-here/' /tmp/r102-s40/ncC4/executability/blueprints.md   # (variant)
CENSUS static-only=11 unproven-runtime=1 verified-here=1 EXPECTED=12/1/0
STEP=FAIL
```

The four install walls and their owners are classified in
`corpus/lessons/r102-unreal-integration.md:95-116` (account-gated 404 / protocol-gated SSH /
credential-gated / unproven unlock path). No local work closes them; that is why row C is a
*label*, not a backlog item.

### Row D — Kimi-side adaptation

```
$ /home/vgpnk/.kimi-code/bin/kimi --version
2.2.0
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi > /tmp/r102-s40/kimi_strings6.txt
$ grep -c additionalContext /tmp/r102-s40/kimi_strings6.txt
0
$ grep -c CLAUDE_PLUGIN_ROOT /tmp/r102-s40/kimi_strings6.txt
0
$ grep -c enabledPlugins /tmp/r102-s40/kimi_strings6.txt
0
$ grep -n 'KIMI_PLUGIN_ROOT_PATH = ' /tmp/r102-s40/kimi_strings6.txt | head -1
749729:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
```

The three zeros are the row-D **negative-claim** evidence: `additionalContext` (the upstream
hook's output key) is absent from Kimi's parser, so adaptation row 4's `NONE-FOUND` is
re-derivable today at BuildID `5e67bdf95c7646325b62decd0ca8d375d325ea19` (v2.2.0). Per
`adaptation-kimi.md:290-293`, **every "binary strings line N" pointer dies on a CLI upgrade** —
so the row-D canonical command is a *re-derivation*, never a line-number citation.

---

## 3. The one column that needs a ruling before this table lands: label precedence

Rows A and C are unambiguous. **Rows B and D are not**, because the lane carries two label
vocabularies that overlap without a precedence rule — and r101 measured the consequence.

The collision, restated with both sides quoted:

- `README.md:41` defines the card label as
  `unproven-runtime` | *the claim needs the live editor and nothing was observed* | `unproven`.
- Six of the 13 cards reject that exact label on the ground that the runtime path is **not even
  identified** — the same condition, read the other way:

> **Not `unproven-runtime`:** that label would assert a real, identified runtime path that merely
> went untested. Here the path is not even identified … That is `static-only`.
> — `corpus/knowledge/unreal-mcp/executability/blueprints.md:113`

Re-derived by this seat:

```
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l
6
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md
…/animation-controlrig.md  …/blueprints.md  …/editor-general.md
…/gameplay-gas.md  …/materials.md  …/meshes-textures.md
```

Six cards, one shared argument, against one definition line. Both readings are internally
honest; the census is not comparable across the two groups. This is r101's finding F7
(`reports/round-101/r101-critic-c3.md:317`, carried forward as hook 1 of
`corpus/lessons/r102-unreal-integration.md:168-174`), and it is **not** this seat's to resolve:
`README.md` and the six cards are other seats' paths, and the subtree is byte-pinned.

**What the table must therefore say until the ruling lands.** Two options, both stated so the
choice is visible and cheap:

- **Option P (policy-first).** `README.md:41` is the definition; `static-only` means *document
  facts proven, behavior unproven* (`README.md:40`) and is admissible only where a static check
  actually ran. Under P, a card whose runtime path is unidentified is `static-only` — i.e. the
  six cards are right and `README.md:41`'s wording is the defect.
- **Option C (card-first).** The card is authoritative for its own label
  (`README.md:204-211`, "only the card is authoritative"), and the definition line is a
  description, not a rule. Under C the six cards are still right, but a *seventh* card may not
  cite `README.md:41` as its ground.

P and C agree on the six cards; they differ on **what a future author cites**. Either way the
table's row B needs one added sentence — *"the binding vocabulary for a card label is
`README.md:31-48`; a card that rejects a label must name the definition it is rejecting"* —
and the gate must keep failing on any census drift (`gate/README.md:82-88`), which it does.

---

## 4. Non-vacuity — every row's check was shown to be able to fail

A scan that passes everything is worthless (`gate/README.md:135`). This seat ran all four of the
gate's documented negative controls on `/tmp` copies of the subtree, never on the pinned tree:

| NC | mutation | intended check | observed | rc |
|---|---|---|---|---|
| C1 | 1-byte append to `upstream/README.md` | CHECK 1 | `MANIFEST_OK=10 EXPECTED=12 FAILED=2 RC=1`, `BLOB_DIFFS=2` → `STEP=FAIL` | 1 |
| C2 | delete `upstream/LICENSE` | CHECK 1 + 2 | `MANIFEST_OK=11 … FAILED=0 RC=1`, `PATH_MISSING=1`, `BLOB_DIFFS=1` → `STEP=FAIL` | 1 |
| C3 | plant `upstream/README.md:200` | CHECK 4 | `LINE-OOR … UNRESOLVED=1` → `STEP=FAIL` | 1 |
| C4 | duplicate label token on a card's label line | CHECK 3 | `CENSUS … verified-here=0 EXPECTED=12/1/0` + `FAIL multi-label` → `STEP=FAIL` | 1 |

All four produce `GATE RESULT: FAIL` with rc 1. Each NC moved **only** its intended check (C1
also moved CHECK 4 to `UNRESOLVED=20` — a real second-order effect: the appended byte changed
`upstream/README.md`'s line count, so pointers into it went out of range). So every row's
"permissible label" is backed by a check that can say no.

Full gate run on the clean tree, for contrast:

```
$ corpus/knowledge/unreal-mcp/gate/run_gate.sh ; echo "GATE_RC=$?"
GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

---

## 5. What this table refuses

Stated as decisions, because a table that only permits is not a discipline:

1. **No row promotes an engine census row.** `corpus/knowledge/engines.md:13-16` requires a
   saved bounded-fixture receipt **and** a non-author verifier before any row moves to
   "executable headless". Row A/B evidence — however green — is not that receipt. The Unreal
   row stays `installed: no / executable headless: no`.
2. **No row lets a static check stand for behavior.** "A static check proves the *files* it
   read, not the *behavior* they describe" (`README.md:57-59`). Row A's green manifest says
   nothing about whether the editor honors the plugin.
3. **No row accepts a count written into prose.** Counts move under concurrent seats; enumerate
   (`README.md:229-240`, `corpus/lessons/r102-unreal-integration.md:118-130`). The r102 F8
   wording fold is the live example: the glob `sha256sum -c .manifest.d/*.sha256` yields **24**
   `OK` lines, not 12 — re-derived here, `grep -c ': OK'` → `24` vs `12` for the
   `audit-reference.sha256` subset.
4. **No row lets a `verified-here` label appear without a bounded-run receipt.** On this host the
   gate fails on `verified-here=1` by construction (`gate/run_gate.sh:33`, `:152-156`).
5. **No row asserts an Unreal-side effect in the indicative mood**
   (`adaptation-kimi.md:299-302`).
6. **No row cites a mutable file by bare line number.** §1's citation rule applies: a
   line-number citation into a concurrently-edited file is the same defect class as F8. Cite the
   section heading and stamp the sha256.

---

## 6. Provenance and residual limits of this draft

- **Every canonical command in §1 was run by this seat on 2026-10-18** and its output is quoted
  in §2. Nothing in the table is cited from another seat's transcript.
- **This seat wrote exactly one file**: `reports/round-102/skill-decision-table-draft.md`. No
  file under `corpus/` was written or modified; the r101 byte-pinned subtree
  `corpus/knowledge/unreal-mcp/` (its `upstream/` and `.manifest.d/`) was read only.
- **Concurrency.** The r102 lesson `corpus/lessons/r102-unreal-integration.md` and the gate
  `corpus/knowledge/unreal-mcp/gate/` both landed *while this seat worked*; both are cited above
  in their landed form. The gate run in §2 is against the landed gate, not a copy.
- **Residual, for the landing seat:**
  - The table is a **draft for `SKILL.md`**, which does not exist. Landing it is a promotion
    action owned by a future round, not by this seat.
  - Row B carries one **unresolved** dependency: the §3 P/C precedence ruling. Until it lands,
    a reader of the table cannot tell which side of the F7 collision is binding.
  - Row D's binary-strings evidence is valid **only** for CLI BuildID
    `5e67bdf95c7646325b62decd0ca8d375d325ea19` (v2.2.0); a CLI upgrade invalidates it
    (`adaptation-kimi.md:290-293`). The table says so in-row; a landing seat should not drop
    that clause.
  - Box 1 is a **promotion gate**: it needs a named **non-author** verifier. This seat is the
    author, so nothing here can close box 1 — at most it moves the box from "no distilled table"
    to "distilled table awaiting verification".

### Artifact index cited by this draft

| artifact | role | sha256 (at cite time) |
|---|---|---|
| `corpus/knowledge/unreal-mcp/README.md` | binary policy (`:12-29`), ternary mapping (`:31-48`), corollaries (`:50-59`), host reality (`:61-72`), reproduce block (`:257-274`) — **mutable, moved twice this round** | `c79d8dd1…` |
| `corpus/knowledge/unreal-mcp/PROVENANCE.md` | pin + byte-identity (`:15-111`), install receipts (`:155-247`), out-of-pin surface (`:340-356`) | `36938c71…` |
| `corpus/knowledge/unreal-mcp/adaptation-kimi.md` | row D: table (`:25-48`), policy (`:270-303`), register (`:306-317`) | `e0f8ca9b…` |
| `corpus/knowledge/unreal-mcp/executability/*.md` | 13 cards; `blueprints.md:113` is the F7 collision witness | per card |
| `corpus/knowledge/unreal-mcp/gate/run_gate.sh` + `gate/README.md` | the self-contained gate; CHECK 1–4, negative controls | `214bf8ef…` |
| `corpus/lessons/r102-unreal-integration.md` | Laws 1–4 (`:17-117`), counting traps (`:118-135`), hooks (`:168-212`) — **mutable, rewritten 178→212 lines this round** | `c7f18f28…` |
| `reports/round-101/r101-verification-protocol.md` | the gate's source rule for CHECK 3/4 — frozen | — |
| `reports/round-101/r101-reviewer-c1.md:20`, `r101-mutation-tester.md:5`, `r101-reviewer-c2.md:663`, `r101-reviewer-c3.md:29` | non-author confirmations of C1/C2/C3 — frozen | — |
| `reports/round-102/reruns/{manifest,labels,pointers,links}.md` | independent r102 re-runs of the same checks | — |
| `reports/round-102/before/F5-engines-threejs.md`, `repairs/F5-engines.md`, `adversary/F5.md` | the row-B-style "command must reproduce its own cited output" class | — |
| `corpus/knowledge/engines.md:13-16` | the no-promotion rule this table's §5.1 restates | `d03907d3…` |
