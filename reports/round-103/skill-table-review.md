# r103 · SEAT-59 SKILL-TABLE-REVIEW — re-review of the decision-table draft against r103 reality

**Seat:** SEAT-59 SKILL-TABLE-REVIEW · round 103 · lane `game-dev-3d-shokunin`
**Owned path written:** `reports/round-103/skill-table-review.md` (this file only). No `corpus/` file,
no pinned subtree byte, no `reports/round-102/**` file, and no other seat's report was written or
modified. Every mutation below was applied to a `/tmp` skeleton, never to the repo.
**Subject under review:** `reports/round-102/skill-decision-table-draft.md`
(SEAT-40 SKILL-TABLE-AUTHOR), **unchanged since r102** —
`sha256 fa360bde7f44de1078edef7d1555492a112f6c56ca443066ccbc3c6b1fb317c2`, 373 lines.
**Prior review carried forward and re-tested:** `reports/round-102/skill-table-review.md` (SEAT-41),
`sha256 809b13123182f80d55f90ac202f050f0bc51835a09521af9e5c88843dcd05d8c`, 450 lines.
**Date:** 2026-10-18 · **Lane HEAD:** `c85a816e227984272a3c29b58aa7f7c1a76f1e9c` (r102 report-last;
work `c6f655d`) · no commit.

**No Unreal runtime claim is made or implied anywhere in this file.** Unreal Editor is not installed on
this host (`which UnrealEditor` → rc 2, re-run below); live-MCP behaviour is unproven by construction.
Row C's posture is the one part of the draft that needs no qualifier, and it is unchanged.

Tags: **[O]** command run by this seat with output quoted · **[C]** cross-referenced to an r103 seat's
independent report · **[F]** the draft's own claim did not reproduce.

---

## 0. Bottom line

The seat brief says "gate behavior now hardened; labels still ternary". **Both clauses are now
literally true**, and getting there took the whole round — the gate was hardened *while this review
ran*, and I watched all four A-items flip from open to landed:

| gate identity | lines | A1 | A2 | A3 | A4 |
|---|---|---|---|---|---|
| `412d1b84…` (HEAD, r102 close-out) | 249 | open | open | open | open |
| `55a76cf8…` (worktree, mid-review) | 294 | open | open | open | **landed** |
| `d226af6f…` (worktree, mid-review) | not captured | **landed** | open | landed | landed |
| **`0c1ca3e1a5606243b45e2c1d4d4ce54d1faea9dcea79048e3c646feca6ab545e`** (worktree, pinned) | **341** | landed | landed | landed | landed |

Only the first and last rows are **clean measurements**; the middle two were taken while the file was
mid-edit and are reported as *observed*, not as evidence. The `open` cells in row 2 are my own runs
against `55a76cf8` (A1 planted `:1-9999` → PASS/exit 0; A2 prose-hijack → `FAIL label-unmarked BAD=1`;
A3 rename → green once citing docs matched). The A2 cell in row 3 was **contaminated** — my mutation
landed at a line the anchored rule does not read, so that run is not evidence either way; §5's
`0c1ca3e1` control supersedes it.

**All four A-items are verified landed** against the pinned `0c1ca3e1` — each with a non-vacuity
control, §5. This is a real depth gain and it is the strongest artifact the round produced. **But the
gate is `M` (worktree-modified) and not yet at HEAD**, so a folding seat must land it; and the round's
own close-out must not read a green gate as F7 being closed (§2 row C).

**Labels are still ternary and F7 is still unresolved.** The subtree `README.md` hash is
**unchanged** (`c79d8dd1…`, the exact value the draft cites), so `README.md:41` and the six dissenting
cards still disagree. The draft's §3 P/C precedence ruling is still owed, and the gate **cannot** see
this defect by construction.

Per-row verdicts against the draft as it stands today:

| row | r102 review verdict | r103 re-review | changed? |
|---|---|---|---|
| **A** — file byte-identity | REVISE (receipts falsified) | **REVISE — receipts still falsified [F]** | no |
| **B** — static parse | REVISE (not executable as written) | **REVISE — still not executable [F]** | no |
| **C** — runtime behavior | PASS with one required qualifier | **PASS — qualifier still owed** | no |
| **D** — Kimi-side adaptation | REVISE (`verified-here` is two vocabularies) | **REVISE — two senses confirmed [O]** | no |

**Fold decision (§6): do not land the table into `SKILL.md` yet.** The four rows are the right four
rows and nothing this round falsified the table's *shape*. What decays is the **provenance column** —
and this round decayed it hard: the draft's ten `run_gate.sh:NN` citations now point at unrelated
lines (§4.1), because the very hardening the round is proud of moved the file.

---

## 1. What actually moved since r102

Measured this seat, not quoted. `[O]`

| surface | r102 close (draft's cite) | r103 now | state |
|---|---|---|---|
| `gate/run_gate.sh` | `214bf8ef…` | worktree **`0c1ca3e1…`**, 341 lines; HEAD `412d1b84…`, 249 lines | **changed twice** — `M`, not yet committed |
| `gate/README.md` | `214bf8ef…` (one cell for two files) | `27f7d809…` | **modified** (SEAT-05 pin updater) |
| subtree `README.md` | `c79d8dd1…` | `c79d8dd1d7c0c7bc934700187ee322d6d1cb20fc03cc974fa62ee2d95b8ee721` | **unchanged** → F7 still open |
| `adaptation-kimi.md` | `e0f8ca9b…` | `084a34cd94806caa497de1ab80df84f95876114048ead83bc158b4d50de8c879`, 506 lines | **changed** (C1 freshness note, 363→506) |
| `corpus/lessons/r102-unreal-integration.md` | `c7f18f28…`, 212 lines | `cf237b8831560c58a3d6d045a9a93e00e1993f798984c08b1abef8a19f9a8ea2`, 217 lines | **changed** |
| `corpus/knowledge/engines.md` | `d03907d3…` | `d03907d3…` | unchanged |
| `PROVENANCE.md` | `36938c71…` | `36938c71…` | unchanged |
| `skill-decision-table-draft.md` | `fa360bde…`, 373 lines | `fa360bde…`, 373 lines | **untouched by r103** |

The gate is green on the live tree, run by this seat **[O]**:

```
$ bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"
MANIFEST_OK=12 EXPECTED=12 FAILED=0 RC=0
CLONE_HEAD=a6aa73ada02a9fb1f5415bec491f9942c519b297
CLONE_DIRTY=0 CLONE_TRACKED=12 PATH_EXTRA=0 PATH_MISSING=0 BLOB_DIFFS=0
CARDS=13 EXPECTED=13 BAD=0
CENSUS static-only=12 unproven-runtime=1 verified-here=0 EXPECTED=12/1/0
NAME_SET=OK NAME_BAD=0
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
GATE_RC=0
```

**`POINTERS` is not a constant and the draft should never have pinned it as one.** Within this single
seat's run the same tree read `88`, then `90 UNRESOLVED=1`, then `90`, then `98`. The swings track
concurrent seats' prose edits, because CHECK 4's pass B counts backtick-wrapped repo-relative paths in
every subtree `.md` — including `gate/README.md`'s own prose. The gate now prints a companion
`POINTER_STRINGS` (98 endpoints from 41 unique strings) precisely to stop the two numbers being
confused, and `gate/README.md:207` carries a pin correction note for the old `87` (SEAT-05) **[C]**.
The draft's §2 quotes `POINTERS=40` and cites `gate/run_gate.sh:192`; both are stale by construction
(§4.1).

---

## 2. Per-row verdicts

### Row A — file byte-identity → **REVISE (receipts still falsified)** [F]

The row itself is sound and its canonical command still reproduces **[O]**:

```
$ cd corpus/knowledge/unreal-mcp && sha256sum -c .manifest.d/audit-reference.sha256 | tail -1
upstream/skills/unreal-skill/SKILL.md: OK            # 12 × OK, rc 0
```

The §2 receipt is still wrong, and the r102 review's disposition — *"re-run the control and paste the
real numbers"* — was never applied because the draft is a frozen r102 artifact. Re-derived on a `/tmp`
copy **[O]**:

```
$ T=/tmp/…/ncA; cp -r corpus/knowledge/unreal-mcp $T; printf '\n' >> $T/upstream/README.md
$ (cd $T && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')     → 11
$ (cd $T && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c 'FAILED')   → 1
$ (cd $T && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep 'FAILED')
upstream/README.md: FAILED
$ awk 'NF==2 && $2 ~ /^upstream\// {print $2}' corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 \
    | sort | uniq -d | wc -l                                                          → 0
```

The draft still prints `MANIFEST_OK=10 EXPECTED=12 FAILED=2 RC=1` (line 114) and still carries the
false explanation *"the append shifted the line count of a file that another manifest row also
covers"* (line 117). The manifest lists each of the 12 paths **exactly once**, so no second row covers
`README.md` and a 1-byte append cannot flip a second file.

**The internal contradiction the fold needs to resolve.** The draft's §1 `+NC` cell (line 62) claims
the append yields a **single** `upstream/README.md: FAILED` — which is *correct*. Its §2 (line 114) and
its §4 table (line 290) both claim two. So the draft is right in one place and wrong in two about its
own control. A landing seat must reconcile all three against the 11/1 measurement.

### Row B — static parse → **REVISE (still not executable as written)** [F]

All three of the r102 review's defects reproduce verbatim **[O]**:

```
$ (cd corpus/knowledge/unreal-mcp && jq -e upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null 2>&1; echo rc=$?)
rc=3                                   # the §1 cell claims → rc 0; the §2 receipt has the `.` filter
$ (cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null 2>&1; echo rc=$?)
rc=0
$ shellcheck upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo "root rc=$?"
root rc=2                              # cwd-ambiguous: the cell names no cwd
$ (cd corpus/knowledge/unreal-mcp && shellcheck upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo rc=$?)
rc=0                                   # only under the DEFAULT ruleset
$ (cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh >/dev/null 2>&1; echo rc=$?)
rc=1                                   # 31 opt-in findings behind the "rc 0" claim
```

The §1 cell (line 63) still writes `→ rc 0` for the dot-less `jq` form and names no cwd for
`shellcheck`. The row's `required evidence` column still accepts "a pointer sweep" while its only
`+NC` exercises the label scan. **Both repairs are mechanical at landing time**: restore the `.`
filter, and prefix both commands with the same `cd corpus/knowledge/unreal-mcp &&` row A already uses.

### Row C — runtime behavior → **PASS; the F7 qualifier is still owed**

Every command reproduces **[O]**, and this is the only row that forbids a claim rather than permitting
one:

```
$ which UnrealEditor UnrealEditor-Cmd >/dev/null 2>&1; echo rc=$?     → rc=2
$ ls /opt/UnrealEngine >/dev/null 2>&1; echo rc=$?                    → rc=2
$ grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l → 6
```

The census is still 6 and the subtree `README.md` hash is unchanged, so the P/C collision the draft's
§3 diagnoses is **exactly as live as it was**. The r102 review's required clause stands unmodified:
*a row-C label is `unproven-runtime` until the F7 precedence ruling lands, and a claim on one of the
six dissenting subsystems must cite the card it contradicts.*

**The gate's A2 hardening does not touch this.** A2 made the *label scan* prose-hijack-proof; it did
nothing about the *definition* collision. CHECK 3 still enforces one allowed token per card and
compares a census, so a card can be perfectly scanned and still disagree with `README.md:41`. This
round's clean `NAME_SET=OK … CENSUS 12/1/0` is **not** evidence F7 closed, and the round report should
say so in the same words the draft's §5 refusal 3 uses about prose counts.

### Row D — Kimi-side adaptation → **REVISE (`verified-here` is still two vocabularies)** [O]

The probes reproduce, including the BuildID **[O]**:

```
$ /home/vgpnk/.kimi-code/bin/kimi --version                    → 2.2.0
$ strings -n 6 /home/vgpnk/.kimi-code/bin/kimi > /tmp/…/ks.txt
$ grep -c additionalContext /tmp/…/ks.txt                      → 0   (pipeline rc 1)
$ grep -c CLAUDE_PLUGIN_ROOT /tmp/…/ks.txt                     → 0
$ grep -c enabledPlugins /tmp/…/ks.txt                         → 0
$ grep -n 'KIMI_PLUGIN_ROOT_PATH = ' /tmp/…/ks.txt | head -1   → 749729:	KIMI_PLUGIN_ROOT_PATH = "kimi.plugin.json";
$ file /home/vgpnk/.kimi-code/bin/kimi | grep -o 'BuildID\[sha1\]=[0-9a-f]*'
BuildID[sha1]=5e67bdf95c7646325b62decd0ca8d375d325ea19
```

The two-sense collision is confirmed at both ends **[O]**:

```
$ sed -n '25,50p' corpus/knowledge/unreal-mcp/adaptation-kimi.md | grep -oE '\| (verified-here|static-only) \|' | sort | uniq -c
      6 | verified-here |
      9 | static-only |
$ sed -n '27p' corpus/knowledge/unreal-mcp/adaptation-kimi.md
# row-probe sense: "reproduced by a command run on this host, output pasted in the row"
$ sed -n '39p' corpus/knowledge/unreal-mcp/README.md
# card sense: "a bounded run of the subsystem actually happened on this host, with a saved receipt"
```

The draft's row-D cell still writes the bare token. **One r103 improvement worth recording:** the C1
freshness note appended this round extends `adaptation-kimi.md` 363 → 506 lines **after** the table, so
the draft's citations into it (`:25-48`, `:270-303`, `:299-302`, `:306-317`, `:290-293`) all still
resolve to the same content **[O]**. That is luck of append-position, not design — and it is precisely
the failure the draft's own §1 citation rule warns about.

---

## 3. Table-level findings from the r102 review: which still hold

| r102 review finding | status at r103 |
|---|---|
| §3.1 §0's **"exhaustive"** is false — `corpus/artifacts/unreal-r22/` has no row | **holds [O]** — `grep -c "unreal-r22\|verify_descriptor" <draft>` → `0`; `python3 corpus/artifacts/unreal-r22/verify_descriptor.py` → rc 0 |
| §3.2 §6's "every canonical command in §1 was run by this seat" is false for row B | **holds [O]** — the dot-less `jq` exits 3 |
| §3.3 §4's heading contradicts row C's own "no pass/fail control by construction" | **holds** — draft line 283 vs line 192, both unchanged |
| §3.4 bare `README.md` is ambiguous between lane root (22 lines) and subtree (278 lines) | **holds [O]** — `wc -l README.md` → 22; `wc -l corpus/knowledge/unreal-mcp/README.md` → 278 |
| §3.5 §2's "independent" re-derivation uses an ephemeral `/tmp/r102-s40/clone` | **holds, and is worse** — see §4.1 |
| §5's six required items (1–6) | **all still open**; item 6 has grown — see §4.1 |

The draft's **§5 refusals remain correct and load-bearing**, unchanged from the r102 review's §4. In
particular refusal 3 (never accept a count written into prose) is now *validated by the round*: the
`POINTERS` pin moved 87 → 88 → 90 → 98 under concurrent seats exactly as that refusal predicts.

---

## 4. New r103 findings (not in the r102 review)

### 4.1 The draft's gate line citations are now invalid — and the draft's own rule 6 forbids them [F]

The gate moved `214bf8ef` → `412d1b84` (249 lines) → `0c1ca3e1` (341 lines). Resolving the draft's gate
citations against the installed gate **[O]**:

| draft cites | draft says it is | actually at that line now |
|---|---|---|
| `gate/run_gate.sh:31-33` | the fail-by-construction on `verified-here=1` | `REPO=` (clone URL) / `EXPECTED_MANIFEST_OK=12` / `EXPECTED_TRACKED=12` |
| `:51-118` | CHECK 1 + CHECK 2 | `printf 'LANE_HEAD=…'` and the hardening preamble |
| `:119-196` | CHECK 3 + CHECK 4 | a comment about a reader not distinguishing FAIL from BLOCKED |
| `:58` | `sha256sum -c .manifest.d/audit-reference.sha256` | `NONREG=$(find … ! -type f …)` — the SEAT-20 non-regular-file scan |
| `:97-98` | the `comm` path-set equality | `C1_RC=$?` / `else` |
| `:105-106` | the CHECK 2 blob compare | `else` / (blank) |
| `:130-131` | `find … executability` | `C2_REF=${GATE_REF:-}` — the new offline path |
| `:135` | `grep -nE "$ALLOWED" "$f" \| head -1` | `else` |
| `:152-156` | the gate failing on `verified-here=1` | `git -C "$CLONE" ls-files \| sort > …` |
| `:192` | the CHECK 4 extraction regex | a CHECK 3 comment: *"the DECLARED label is the token on the first line that is a DECLARATION…"* |

Not one of the ten resolves to the content the draft names. **This is the draft violating its own §1
citation rule** — its §5 refusal 6: *"No row cites a mutable file by bare line number"* — and its own
§1 rule text: *"cite a mutable artifact by section heading plus a sha256 stamp, not by bare line
number."* The rule is right; the draft applied it to `README.md` but not to the gate, the single most
volatile file in the subtree. **A landing seat must re-cite every gate reference by check name plus
the gate's sha256, and must carry no gate line number forward.**

### 4.2 Three of the draft's seven artifact-index hashes are stale

The draft's §6 artifact index is hash-stamped, which is the right shape — but three rows have moved,
two of them this round **[O]**:

| artifact | draft's stamp | live stamp | status |
|---|---|---|---|
| `corpus/knowledge/unreal-mcp/README.md` | `c79d8dd1…` | `c79d8dd1…` | current |
| `PROVENANCE.md` | `36938c71…` | `36938c71…` | current |
| `corpus/knowledge/engines.md` | `d03907d3…` | `d03907d3…` | current |
| `adaptation-kimi.md` | `e0f8ca9b…` | `084a34cd…` | **stale** (r103 C1 note) |
| `corpus/lessons/r102-unreal-integration.md` | `c7f18f28…` | `cf237b88…` | **stale** |
| `gate/run_gate.sh` + `gate/README.md` | `214bf8ef…` (one stamp for two files) | script `0c1ca3e1…`, README `27f7d809…` | **stale, and conflated** |
| `executability/*.md` | "per card" | — | not a stamp |

The gate row is the worst: one hash for a script *and* a README that no longer share a value and never
did after this round's README edit.

### 4.3 A9's first sub-item is fixed in the installed README

The fold-spec's A9 wanted `gate/README.md`'s "three mutations must each turn the gate red" corrected.
It **has** been **[O]**:

```
$ grep -c '^# C[0-9]' corpus/knowledge/unreal-mcp/gate/README.md          → 6
$ grep -n "three mutations" corpus/knowledge/unreal-mcp/gate/README.md
161:A scan that passes everything is worthless. These mutation controls (C1–C6, plus C7 where listed) must each turn the gate red.
```

The sentence now matches the six shell blocks and names C7's conditional status. A9's second
sub-item — C7's unreproducible pinned `SKIPPED_CONTROL_SENTINELS=2` — is outside this seat's
verification and is not re-tested here. Note `reports/round-103/gate/docs-sync.md` (SEAT-20) **[C]**
flags the remaining README/gate mismatches; that is the seat of record for this surface.

---

## 5. A1–A4: all four verified landed against the pinned gate

The brief states the gate is hardened. That is now **true**, and it was not true when this review
began. Each row below is my own run against a `/tmp` skeleton that reproduces the lane layout, so the
gate's repo-relative sweep resolves and does not go spuriously red. Baseline on that skeleton, with
gate `0c1ca3e1…` **[O]**:

```
$ bash $S/gate/run_gate.sh
NAME_SET=OK NAME_BAD=0
POINTERS=98 POINTER_STRINGS=41 SKIPPED_CONTROL_SENTINELS=0 UNRESOLVED=0
GATE RESULT: PASS (checks failed: 0)
```

| item | spec | installed mechanism | my falsification + non-vacuity control |
|---|---|---|---|
| **A1** | validate **all** endpoints of `:a-b` / `a,b` | **landed** — `for ln in $(printf '%s' "$rest" \| tr ',-' '  ')` (line 306); `POINTERS` counts endpoints, `POINTER_STRINGS` counts unique strings | plant `upstream/README.md:1-9999` → `LINE-OOR … (max 112)`, `UNRESOLVED=1`, **exit 1**. Control: in-range `upstream/README.md:1-112` → `UNRESOLVED=0`, **exit 0** |
| **A2** | prose-hijack-proof label rule | **landed** — anchored `LABEL_RE` (lines 212-215) matching only the five declaration shapes the cards actually use | prose line naming `verified-here` above a correctly labelled card → `CARDS=13 BAD=0`, **PASS** (was `FAIL label-unmarked BAD=1`). Control: duplicate token on the declaration → `FAIL multi-label … BAD=1`, **exit 1** |
| **A3** | pinned card-**name** set comparison | **landed** — `PINNED_CARD_NAMES` both directions, `NAME_SET=OK/BAD NAME_BAD=n` (lines 245-256) | rename `sequencer.md` → `sequence-typo.md` **and** update the 4 citing docs → `NAME_SET=BAD NAME_BAD=2`, **exit 1** (was a full false PASS). Control: unmodified → `NAME_SET=OK NAME_BAD=0` |
| **A4** | distinct `BLOCKED` signal + declared exit 2 | **landed** — `C2_BLOCKED`, `STEP=BLOCKED`, `GATE_REF`/`C2_REF` offline path, `exit 2` at line 337 | unreachable `REPO` → `CHECK 2 BLOCKED (network)`, `STEP=BLOCKED`, `GATE RESULT: BLOCKED`, **exit 2**. Control: `GATE_REF=<clone at pin>` → `GATE REF=… (offline reference; no clone attempted)`, **PASS, exit 0** |

Two of my own runs were wrong before they were right, and the corrections matter to anyone repeating
this:

1. **A4, first attempt:** I wrote the mutated script to `/tmp` outside `gate/`, so the gate's
   `SUB=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)` resolved to the wrong tree. The test script
   must sit **inside `gate/`**.
2. **A4, second attempt:** my `sed 's|^REPO=.*|…|'` hit **both** `REPO=` lines — line 31 (the clone
   URL) and line 315 (`REPO=$(cd "$SUB/../../.." && pwd)`, CHECK 4's lane-root base). That produced 26
   bogus `MISSING-PATH-REL` lines and a red gate for the wrong reason. The gate has **two** `REPO=`
   variables; anchor the substitution to the URL.

Independent r103 corroboration, cross-referenced rather than restated **[C]**:
`reports/round-103/gate/a3-attack.md` (SEAT-13) proved the rename was caught only *incidentally* by the
pointer sweep and that a consistent rename went fully green — the A3 gap; `a4-attack.md` (SEAT-14)
recorded *"FALSIFIED. The A4 defect stands exactly as folded"*; `a2-attack.md` (SEAT-09) recorded a
false-PASS variant of the label rule; `docs-sync.md` (SEAT-20) tracked README-vs-gate drift. My A1 and
A2-landed runs are the two this round did not otherwise cover.

**Residual after A1–A4:** the gate is still `M` in the worktree (`git status --porcelain` →
` M corpus/knowledge/unreal-mcp/gate/run_gate.sh`), so the hardening exists only as uncommitted bytes.
Until a commit lands, the r102 close-out gate `412d1b84…` remains what HEAD describes, and the fold
queue's A-items should be marked *landed-uncommitted*, not closed.

---

## 6. Fold decision and recommendation

**Recommendation: do NOT land the table into `SKILL.md` as a file edit yet.** `SKILL.md` does not exist
in this lane (`ls SKILL.md` → `No such file or directory`; `reports/round-103/seats-ledger.md` §2
confirms no seat-level `SKILL.md` exists anywhere outside the pinned upstream) **[O][C]**, and SHONEN
box 1 is a **promotion gate requiring a named non-author verifier** (`SHONEN.md:1,10-11`). The box is
still `[ ]`. Landing a table whose four rows are 3× REVISE would move it from "no distilled table" to
"distilled table a stranger cannot execute", which is worse than leaving it open.

**The four rows are the right four rows.** Nothing in r103 falsified the table's *shape*: the
claim-type partition, the `+NC` requirement, the two-vocabulary legend, and all six §5 refusals survive
re-test. What decays is the **provenance column** (§4.1, §4.2).

Ordered, falsifiable landing conditions — each a command, not a judgement:

1. **Re-cite the gate by name + hash, zero line numbers.** Every `gate/run_gate.sh:NN` becomes
   `CHECK n <name>`, `gate/run_gate.sh` @ the landed sha256. Acceptance:
   `grep -cE 'run_gate\.sh:[0-9]' <landed table>` → `0`.
2. **Fix row A's control to 11/1 and delete the false sentence.** Acceptance: the landed text shows
   `MANIFEST_OK=11 EXPECTED=12 FAILED=1 RC=1`, and `grep -c "another manifest row" <landed table>` → `0`.
3. **Fix row B's two commands** (restore the `.` filter; state a cwd) **and name the shellcheck
   ruleset** (`default` → rc 0; `-o all` → rc 1, 31 findings). Acceptance: copy-pasting the row's cell
   commands from the lane root reproduces the row's printed rcs.
4. **Inline row D's `verified-here` disambiguation and add row C's F7 clause** — both *in the cell*,
   not in §3 below the table, because a consumer copying a row never reads §3.
5. **Re-stamp the artifact index** (§4.2) and qualify §0's "exhaustive" (add an E-row for
   `corpus/artifacts/unreal-r22/`, or narrow the claim to "the pinned subtree").
6. **Then, and only then, a named non-author verifier** moves box 1 from `[ ]` to `[x]` — per
   `SHONEN.md:10-11`, self-attestation counts only as `[~]`, and both the author (SEAT-40) and this
   reviewer (SEAT-59) are excluded.

**On the brief's "land in SKILL.md as its own file edit in a future round, per SHONEN box 1": yes —
but gated on items 1–5, and after the gate hardening is committed.** The table is worth landing; the
current file is not yet the thing to land.

---

## 7. Reproduce

```sh
cd /home/vgpnk/Projects/shokunin/game-dev-3d-shokunin

# subjects, frozen
sha256sum reports/round-102/skill-decision-table-draft.md   # fa360bde… 373 lines
sha256sum reports/round-102/skill-table-review.md           # 809b1312… 450 lines

# §1 — the gate, live; note worktree != HEAD
sha256sum corpus/knowledge/unreal-mcp/gate/run_gate.sh                       # 0c1ca3e1…
git show HEAD:corpus/knowledge/unreal-mcp/gate/run_gate.sh | sha256sum       # 412d1b84…
git status --porcelain corpus/knowledge/unreal-mcp/gate/run_gate.sh          # " M …"
bash corpus/knowledge/unreal-mcp/gate/run_gate.sh; echo "GATE_RC=$?"         # PASS, NAME_SET=OK, POINTERS=98

# §2 row A — the falsified control, re-derived on a /tmp copy
T=$(mktemp -d); cp -r corpus/knowledge/unreal-mcp "$T/sub"; printf '\n' >> "$T/sub/upstream/README.md"
(cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c ': OK')     # 11
(cd "$T/sub" && sha256sum -c .manifest.d/audit-reference.sha256 2>&1 | grep -c 'FAILED')   # 1
awk 'NF==2 && $2 ~ /^upstream\// {print $2}' corpus/knowledge/unreal-mcp/.manifest.d/audit-reference.sha256 \
  | sort | uniq -d | wc -l                                                                 # 0

# §2 row B — the cell command as written vs as receipted
(cd corpus/knowledge/unreal-mcp && jq -e upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null; echo rc=$?)   # 3
(cd corpus/knowledge/unreal-mcp && jq -e . upstream/.claude-plugin/plugin.json upstream/hooks/hooks.json >/dev/null; echo rc=$?) # 0
shellcheck upstream/hooks/unreal-context.sh >/dev/null; echo rc=$?                                                              # 2
(cd corpus/knowledge/unreal-mcp && shellcheck -o all upstream/hooks/unreal-context.sh >/dev/null; echo rc=$?)                    # 1

# §2 row C / row D
which UnrealEditor UnrealEditor-Cmd >/dev/null; echo rc=$?                                      # 2
grep -rln 'Not `unproven-runtime`' corpus/knowledge/unreal-mcp/executability/*.md | wc -l       # 6
/home/vgpnk/.kimi-code/bin/kimi --version                                                       # 2.2.0
strings -n 6 /home/vgpnk/.kimi-code/bin/kimi | grep -c additionalContext                        # 0, rc 1

# §4.1 — the draft's gate citations vs the installed gate
sed -n '31,33p;58p;97,98p;105,106p;130,131p;135p;152,156p;192p' corpus/knowledge/unreal-mcp/gate/run_gate.sh

# §4.2 — artifact-index staleness
sha256sum corpus/knowledge/unreal-mcp/adaptation-kimi.md corpus/lessons/r102-unreal-integration.md \
          corpus/knowledge/unreal-mcp/gate/run_gate.sh corpus/knowledge/unreal-mcp/gate/README.md

# §5 — the A1–A4 controls. Build a /tmp skeleton that reproduces the LANE layout
# (corpus/knowledge/unreal-mcp plus stub lane-level targets), confirm it is green
# (NAME_SET=OK, POINTERS=98 UNRESOLVED=0, PASS), then:
#   A1: append '\nsee upstream/README.md:1-9999\n' to executability/materials.md
#       → LINE-OOR … (max 112), exit 1;  change to :1-112 → exit 0
#   A2: insert a prose line naming a token above a card's declaration
#       → CARDS=13 BAD=0, PASS;  duplicate the token on the declaration → FAIL multi-label, exit 1
#   A3: rename executability/sequencer.md and update the 4 citing docs
#       → NAME_SET=BAD NAME_BAD=2, exit 1;  unmodified → NAME_SET=OK NAME_BAD=0
#   A4: copy the gate INTO gate/ and replace ONLY the line-31 clone URL:
#       sed 's|^REPO=https://github.com/EpicGames/unreal-engine-skills-for-claude-code-plugin|REPO=https://github.com/EpicGames/nope-xyz|'
#       → CHECK 2 BLOCKED (network) / STEP=BLOCKED / GATE RESULT: BLOCKED, exit 2
#       GATE_REF=<clone at the pin> bash …/run_gate.sh → PASS, exit 0
#     Do NOT use 's|^REPO=.*|…|': line 315 is a second REPO= (CHECK 4's lane-root base).
```

---

## 8. Limits of this review

- **I am a reviewer, not the author.** I edited no file under `corpus/` and resolved no defect I found.
  Every mutation in §5 was applied to a `/tmp` skeleton; the live repo was only read. The one subtree
  file that moved during this seat's run — `adaptation-kimi.md` — moved because of a concurrent seat.
- **The tree is live, and this round it moved a lot.** The gate went through four distinct identities
  while I reviewed (`412d1b84` → `55a76cf8` → `d226af6f` → `0c1ca3e1`), `POINTERS` read 88/90/98, and
  `/tmp` hit its quota mid-run twice, corrupting two of my measurements before I rebuilt. Every number
  here is pinned to the identities in §1/§5 — **re-hash before acting on any of them.**
- **The A1–A4 verdicts are worktree facts, not HEAD facts.** `run_gate.sh` is `M`; HEAD still carries
  `412d1b84…`, where all four are open. A folding seat must land the hardening before marking the
  queue's A-items closed.
- **I re-verified the four rows, the six r102 table-level findings, and the A1–A4 landed status.** I
  did not re-audit all ~40 draft citations — §4.1 covers the gate subset mechanically and §4.2 the
  artifact index exhaustively. A range being *in bounds* is not a claim that the quoted words are on
  those lines; I read the load-bearing ones.
- **No Unreal runtime claim.** The editor is not installed; nothing above asserts live-editor
  behaviour, and row C's inability to be controlled is a property of this host, not a defect.
